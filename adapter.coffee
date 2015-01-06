# Copyright (c) 2013 GitHub Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Taken from hubot at commit 71d1c686d9ffdfad54751080c699979fa17190a1 and modified to fit current use.

{EventEmitter} = require 'events'

class Adapter extends EventEmitter
  # An adapter is a specific interface to a chat source for bot.
  #
  # bot - A bot instance.
  constructor: (@chat) ->

    # Public: Raw method for sending data back to the chat source. Extend this.
    #
    # envelope - A Object with message, room and user details.
    # strings  - One or more Strings for each message to send.
    #
    # Returns nothing.
  send: (envelope, strings...) ->

    # Public: Raw method for sending emote data back to the chat source.
    # Defaults as an alias for send
    #
    # envelope - A Object with message, room and user details.
    # strings  - One or more Strings for each message to send.
    #
    # Returns nothing.
  emote: (envelope, strings...) ->
    @send envelope, strings...

  # Public: Raw method for building a reply and sending it back to the chat
  # source. Extend this.
  #
  # envelope - A Object with message, room and user details.
  # strings  - One or more Strings for each reply to send.
  #
  # Returns nothing.
  reply: (envelope, strings...) ->

    # Public: Raw method for invoking the bot to run. Extend this.
    #
    # Returns nothing.
  run: ->

    # Public: Raw method for shutting the bot down. Extend this.
    #
    # Returns nothing.
  close: ->

    # Public: Dispatch a received message to the bot.
    #
    # Returns nothing.
  receive: (message) ->
    @chat.receive message

module.exports = Adapter
