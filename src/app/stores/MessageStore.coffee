DB = require 'stores/helpers/ParseBackend'

# Pegg
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'

# Famo.us
EventEmitter = require 'famous/src/core/EventEmitter'

class MessageStore extends EventEmitter

  _messages:
    first_card: "Welcome to your first card! Do this to play, that to do the other thing."

  _show: (type) ->
    @_type = type
    # showMessage = DB.getUserPref 'show_help__first_card', UserStore.getUser().id
    # if showMessage
    #   @_dismiss type
    #   @emit Constants.stores.SHOW_MESSAGE

  _dismiss: (type) ->
    # DB.saveUserPref 'show_help__first_card', false, UserStore.getUser().id

  getMessage: ->
    @_messages[@_type]

messages = new MessageStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to MessageStore
  switch action.actionType
    when Constants.actions.SHOW_MESSAGE
      messages._show action.type

module.exports = messages
