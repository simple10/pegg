EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _nextSet: null

  fetchGame: (gameID) ->
    Sets = Parse.Object.extend("Sets")
    query = new Parse.Query(Sets)
    query.exists "title"
    query.find
      success: (results) =>
        @_game = results
        @emit Constants.stores.CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  getGame: ->
    @_game

play = new PlayStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.GAME_FETCH
      play.fetchGame action.gameID


module.exports = play
