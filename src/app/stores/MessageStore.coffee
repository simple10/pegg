DB = require 'stores/helpers/ParseBackend'

# Pegg
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'

# Famo.us
EventEmitter = require 'famous/core/EventEmitter'

class MessageStore extends EventEmitter

  _type: ''

  _show: (type) ->
    @_type = type
    @emit Constants.stores.SHOW_MESSAGE

  getMessage: ->
    "Help Message (#{@_type})"

messages = new MessageStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to MessageStore
  switch action.actionType
    when Constants.actions.SHOW_MESSAGE
      messages._show action.type

module.exports = messages
