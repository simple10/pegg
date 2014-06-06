EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _game: null

  fetchGame: (gameID) ->
    Sets = Parse.Object.extend("Sets")
    query = new Parse.Query(Sets)
    query.equalTo "approved", true
    query.find
      success: (results) =>
        @_game = results
        @emit Constants.stores.CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  recordAnswer: (cardID, choice) ->
    #TODO: send data to Parse
    @emit Constants.stores.NEXTCARD

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
    when Constants.actions.CARD_ANSWER
      play.recordAnswer action.cardID, action.choice


module.exports = play
