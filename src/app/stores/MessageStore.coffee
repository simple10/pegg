DB = require 'stores/helpers/ParseBackend'

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'

# Famo.us
EventEmitter = require 'famous/src/core/EventEmitter'

class MessageStore extends EventEmitter

  _messages:
    tutorial__first_unpreffed_card: "Yo! This is a new question for you. Answer about yourself so friends can pegg you."
    tutorial__first_pegg_card: "Time to rally! Tap each card to answer questions about your friends."

  _show: (type) ->
    @_type = type
    DB.getUserSetting "show:#{type}", UserStore.getUser().id, true
      .then (showMessage) =>
        if showMessage
          @emit Constants.stores.SHOW_MESSAGE
          @_dismiss type

  _dismiss: (type) ->
    DB.saveUserSetting "show:#{type}", false, UserStore.getUser().id

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
