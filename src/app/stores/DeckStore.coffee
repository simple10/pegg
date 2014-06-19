EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class DeckStore extends EventEmitter
  _deck: null

  fetch: ->
    return

  getDecks: ->
    @_nextSet

decks = new DeckStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.DECKS_FETCH
      decks.fetch action.page


module.exports = decks
