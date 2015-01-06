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

class Response
  # Public: Responses are sent to matching listeners. Messages know about the
  # content and user that made the original message, and how to reply back to
  # them.
  #
  # bot   - A Robot instance.
  # message - A Message instance.
  # match   - A Match object from the successful Regex match.
  constructor: (@bot, @message, @match) ->
    @envelope =
      room: @message.room
      user: @message.user
      message: @message

  # Public: Posts a message back to the chat source
  #
  # strings - One or more strings to be posted. The order of these strings
  #           should be kept intact.
  #
  # Returns nothing.
  send: (strings...) ->
    @bot.adapter.send @envelope, strings...

  # Public: Posts an emote back to the chat source
  #
  # strings - One or more strings to be posted. The order of these strings
  #           should be kept intact.
  #
  # Returns nothing.
  emote: (strings...) ->
    @bot.adapter.emote @envelope, strings...

  # Public: Posts a message mentioning the current user.
  #
  # strings - One or more strings to be posted. The order of these strings
  #           should be kept intact.
  #
  # Returns nothing.
  reply: (strings...) ->
    @bot.adapter.reply @envelope, strings...

  # Public: Picks a random item from the given items.
  #
  # items - An Array of items.
  #
  # Returns a random item.
  random: (items) ->
    items[ Math.floor(Math.random() * items.length) ]

  # Public: Tell the message to stop dispatching to listeners
  #
  # Returns nothing.
  finish: ->
    @message.finish()

  # Public: Creates a scoped http client with chainable methods for
  # modifying the request. This doesn't actually make a request though.
  # Once your request is assembled, you can call `get()`/`post()`/etc to
  # send the request.
  #
  # Returns a ScopedClient instance.
  http: (url) ->
    @bot.http(url)

module.exports = Response
