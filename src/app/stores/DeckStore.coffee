EventEmitter = require 'famous/src/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class DeckStore extends EventEmitter
  _decks: null

  fetch: ->
    return

  getDecks: ->
    @_decks

decks = new DeckStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to DeckStore
  switch action.actionType
    when Constants.actions.DECKS_FETCH
      decks.fetch action.page


module.exports = decks
