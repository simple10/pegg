EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _game: null
  _card: null

  fetchGame: (gameID) ->
    Sets = Parse.Object.extend("Sets")
    query = new Parse.Query(Sets)
    query.equalTo "approved", true
    #query.equalTo "approved", null
    query.find
      success: (results) =>
        #debugger
        @_game = results
        @emit Constants.stores.CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  saveAnswer: (choice) ->
    console.log "choice: " + choice
    #TODO: send data to Parse
    @emit Constants.stores.CARD_ANSWERED

  saveRating: (rating) ->
    console.log "rating: " + rating
      #TODO: send data to Parse
    @emit Constants.stores.CARD_RATED

  nextCard: (cardID) ->
    console.log "cardID: " + cardID
    @_card = cardID


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
      play.saveAnswer action.choice
    when Constants.actions.CARD_RATE
      play.saveRating action.rating
    when Constants.actions.CARD_PICK
      play.nextCard action.cardID


module.exports = play
