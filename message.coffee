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


class Message
  # Represents an incoming message from the chat.
  #
  # user - A User instance that sent the message.
  constructor: (@user, @done = false) ->
    @room = @user.room

  # Indicates that no other Listener should be called on this object
  #
  # Returns nothing.
  finish: ->
    @done = true

class TextMessage extends Message
  # Represents an incoming message from the chat.
  #
  # user - A User instance that sent the message.
  # text - A String message.
  # id   - A String of the message ID.
  constructor: (@user, @text, @id) ->
    super @user

  # Determines if the message matches the given regex.
  #
  # regex - A Regex to check.
  #
  # Returns a Match object or null.
  match: (regex) ->
    @text.match regex

  # String representation of a TextMessage
  #
  # Returns the message text
  toString: () ->
    @text

# Represents an incoming user entrance notification.
#
# user - A User instance for the user who entered.
# text - Always null.
# id   - A String of the message ID.
class EnterMessage extends Message

  # Represents an incoming user exit notification.
  #
  # user - A User instance for the user who left.
  # text - Always null.
  # id   - A String of the message ID.
class LeaveMessage extends Message

class CatchAllMessage extends Message
  # Represents a message that no matchers matched.
  #
  # message - The original message.
  constructor: (@message) ->
    super @message.user

module.exports = {
  Message
  TextMessage
  EnterMessage
  LeaveMessage
  CatchAllMessage
}
