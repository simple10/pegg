EventEmitter = require 'famous/core/EventEmitter'

class MessageState extends EventEmitter
  constructor: (script) ->
    super
    @_script = script
    @_currentMessage = {}

  getMessage: (type) ->
    index = @_currentMessage[type] or 0
    @_currentMessage[type] = index + 1
    @_script[type][index]

module.exports = MessageState
