# Copyright (c) 2012 Fernando Ortiz

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Taken from hubot-irc at commit 17c5d58799830f48dd0d0b215c0a9506139fddee and modified to fit current use.

# Hubot dependencies
{ChatUser, Bot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require '../index'

# Custom Response class that adds a sendPrivate method
class IrcResponse extends Response
  sendPrivate: (strings...) ->
    @bot.adapter.sendPrivate @envelope, strings...

# Irc library
Irc = require 'irc'

Log = require('log')
logger = sails.log

class TwitchBot extends Adapter
  send: (envelope, strings...) ->
    target = @_getTargetFromEnvelope envelope

    unless target
      return logger.error "ERROR: Not sure who to send to. envelope=", envelope

    for str in strings
      @bot.say target, str

  emote: (envelope, strings...) ->
    target = @_getTargetFromEnvelope envelope

    unless target
      return logger.error "ERROR: Not sure who to send to. envelope=", envelope

    for str in strings
      @bot.action target, str

  reply: (envelope, strings...) ->
    for str in strings
      @send envelope.user, "#{envelope.user.name}: #{str}"

  join: (channel) ->
    self = @
    @bot.join channel, () ->
      logger.info('joined %s', channel)

      selfUser = self.getUserFromName self.bot.name
      self.receive new EnterMessage(selfUser)

  part: (channel) ->
    self = @
    @bot.part channel, () ->
      logger.info('left %s', channel)

      selfUser = self.getUserFromName self.bot.name
      self.receive new LeaveMessage(selfUser)

  getUserFromName: (name) ->
    new ChatUser name

  getUserFromId: (id) ->
    new ChatUser id

  createUser: (channel, from) ->
    user = @getUserFromId from
    user.name = from

    if channel.match(/^[&#]/)
      user.room = channel
    else
      user.room = null
    user

  command: (command, strings...) ->
    @bot.send command, strings...

  checkCanStart: ->
    if not @chat.name
      throw new Error("Nick is not defined")
    else if not sails.config.chat.twitch.token
      throw new Error("Bot chat token is not defined")
    else if not sails.config.chat.twitch.room
      throw new Error("Room is not defined")

  unfloodProtection: (unflood) ->
    unflood == 'true' or !isNaN(parseInt(unflood))

  unfloodProtectionDelay: (unflood) ->
    unfloodProtection = @unfloodProtection(unflood)
    unfloodValue = parseInt(unflood) or 1000

    if unfloodProtection
      unfloodValue
    else
      0

  run: ->
    self = @

    do @checkCanStart

    options =
      nick:     @chat.name
      realName: @chat.name
      port:     sails.config.chat.twitch.port or 6667
      rooms:    [sails.config.chat.twitch.room]
      server:   sails.config.chat.twitch.server or 'irc.twitch.tv'
      password: sails.config.chat.twitch.token
      ignoreUsers: []
      nickpass: null
      nickusername: @chat.name
      connectCommand: null
      fakessl:  false
      certExpired: false
      unflood:  true
      debug:    sails.config.chat.twitch.debug or false
      usessl:   false
      userName: @chat.name

    client_options =
      userName: options.userName
      realName: options.realName
      password: options.password
      debug: options.debug
      port: options.port
      stripColors: true
      secure: options.usessl
      selfSigned: options.fakessl
      certExpired: options.certExpired
      floodProtection: @unfloodProtection(options.unflood),
      floodProtectionDelay: @unfloodProtectionDelay(options.unflood),

    client_options['channels'] = options.rooms unless options.nickpass

    # Override the response to provide a sendPrivate method
    @chat.Response = IrcResponse

    @chat.name = options.nick
    bot = new Irc.Client options.server, options.nick, client_options

    next_id = 1
    user_id = {}

    if options.nickpass?
      identify_args = ""

      if options.nickusername?
        identify_args += "#{options.nickusername} "

      identify_args += "#{options.nickpass}"

      bot.addListener 'notice', (from, to, text) ->
        if from is 'NickServ' and text.toLowerCase().indexOf('identify') isnt -1
          bot.say 'NickServ', "identify #{identify_args}"
        else if options.nickpass and from is 'NickServ' and
          (text.indexOf('Password accepted') isnt -1 or
            text.indexOf('identified') isnt -1)
          for room in options.rooms
            @join room

    if options.connectCommand?
      bot.addListener 'registered', (message) ->
        # The 'registered' event is fired when you are connected to the server
        strings = options.connectCommand.split " "
        self.command strings.shift(), strings...

    bot.addListener 'names', (channel, nicks) ->
      for nick of nicks
        self.createUser channel, nick

    bot.addListener 'notice', (from, to, message) ->
      return unless from

      if from in options.ignoreUsers
        logger.info('Ignoring user: %s', from)
        # we'll ignore this message if it's from someone we want to ignore
        return

      logger.info "NOTICE from #{from} to #{to}: #{message}"

      user = self.createUser to, from
      self.receive new TextMessage(user, message)

    bot.addListener 'message', (from, to, message) ->
      if options.nick.toLowerCase() == to.toLowerCase()
        # this is a private message, let the 'pm' listener handle it
        return

      if from in options.ignoreUsers
        logger.info('Ignoring user: %s', from)
        # we'll ignore this message if it's from someone we want to ignore
        return

      logger.debug "From #{from} to #{to}: #{message}"

      user = self.createUser to, from
      if user.room
        logger.info "#{to} <#{from}> #{message}"
      else
        unless message.indexOf(to) == 0
          message = "#{to}: #{message}"
        logger.debug "msg <#{from}> #{message}"

      self.receive new TextMessage(user, message)

    bot.addListener 'action', (from, to, message) ->
      logger.debug " * From #{from} to #{to}: #{message}"

      if from in options.ignoreUsers
        logger.info('Ignoring user: %s', from)
        # we'll ignore this message if it's from someone we want to ignore
        return

      user = self.createUser to, from
      if user.room
        logger.debug "#{to} * #{from} #{message}"
      else
        logger.debug "msg <#{from}> #{message}"

      self.receive new TextMessage(user, message)

    bot.addListener 'error', (message) ->
      logger.error('ERROR: %s: %s', message.command, message.args.join(' '))

    bot.addListener 'join', (channel, who) ->
      logger.info('%s has joined %s', who, channel)
      user = self.createUser channel, who
      user.room = channel
      self.receive new EnterMessage(user)

    bot.addListener 'part', (channel, who, reason) ->
      logger.info('%s has left %s: %s', who, channel, reason)
      user = self.createUser '', who
      user.room = channel
      msg = new LeaveMessage user
      msg.text = reason
      self.receive msg

    bot.addListener 'quit', (who, reason, channels) ->
      logger.info '%s has quit: %s (%s)', who, channels, reason
      for ch in channels
        user = self.createUser '', who
        user.room = ch
        msg = new LeaveMessage user
        msg.text = reason
        self.receive msg

    @bot = bot

    self.emit "connected"

  _getTargetFromEnvelope: (envelope) ->
    user = null
    room = null
    target = null

    # as of hubot 2.4.2, the first param to send() is an object with 'user'
    # and 'room' data inside. detect the old style here.
    if envelope.reply_to
      user = envelope
    else
      # expand envelope
      user = envelope.user
      room = envelope.room

    if user
      # most common case - we're replying to a user in a room
      if user.room
        target = user.room
        # reply directly
      else if user.name
        target = user.name
        # replying to pm
      else if user.reply_to
        target = user.reply_to
        # allows user to be an id string
      else if user.search?(/@/) != -1
        target = user
    else if room
      # this will happen if someone uses bot.messageRoom(jid, ...)
      target = room

    target

module.exports.use = (chat) ->
  new TwitchBot chat
