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

{inspect} = require 'util'

{TextMessage} = require './message'

class Listener
  # Listeners receive every message from the chat source and decide if they
  # want to act on it.
  #
  # bot    - A Robot instance.
  # matcher  - A Function that determines if this listener should trigger the
  #            callback.
  # callback - A Function that is triggered if the incoming message matches.
  constructor: (@bot, @matcher, @callback) ->

    # Public: Determines if the listener likes the content of the message. If
    # so, a Response built from the given Message is passed to the Listener
    # callback.
    #
    # message - A Message instance.
    #
    # Returns a boolean of whether the matcher matched.
  call: (message) ->
    if match = @matcher message
      @bot.logger.debug "Message '#{message}' matched regex /#{inspect @regex}/" if @regex

      @callback new @bot.Response(@bot, message, match)
      true
    else
      false

class TextListener extends Listener
  # TextListeners receive every message from the chat source and decide if they
  # want to act on it.
  #
  # bot    - A Robot instance.
  # regex    - A Regex that determines if this listener should trigger the
  #            callback.
  # callback - A Function that is triggered if the incoming message matches.
  constructor: (@bot, @regex, @callback) ->
    @matcher = (message) =>
      if message instanceof TextMessage
        message.match @regex

module.exports = {
  Listener
  TextListener
}
