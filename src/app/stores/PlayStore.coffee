EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _game: null
  _card: null
  _comments: null

  fetchGame: (gameID) ->
    # TODO: if offline, load from localStorage
    Sets = Parse.Object.extend("Sets")
    query = new Parse.Query(Sets)
    #query.equalTo "approved", true
    query.equalTo "approved", null
    query.find
      success: (results) =>
        @_game = results
        @emit Constants.stores.CHANGE
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message

  fetchComments: () ->
    @_comments = [ { text: 'some comment', imageUrl: 'images/mascot_medium.png'},
      { text: 'another comment', imageUrl: 'images/mascot_medium.png'},
      { text: 'hello dixie dear oh me oh my this is a comment!', imageUrl: 'images/mascot_medium.png'},
      { text: 'this is the craziest bullshit ever...', imageUrl: 'images/mascot_medium.png'},
    ]
    @emit Constants.stores.COMMENTS_FETCHED
    ###Comments = Parse.Object.extend("Comment")
    query = new Parse.Query(Comments)
    query.equalTo "userId", userId
    query.equalTo "cardId", @_cardId
    query.include "author"
    query.find
      success: (results) =>
        @_comments = results
        @emit Constants.stores.COMMENTS_FETCHED
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message###

  saveAnswer: (choice) ->
    console.log "choice: " + choice
    #TODO: send data to Parse
    @emit Constants.stores.CARD_ANSWERED

  saveRating: (rating) ->
    console.log "rating: " + rating
      #TODO: send data to Parse
    if @_card is "qZxzk3ipSd"
      @emit Constants.stores.UNLOCK_ACHIEVED
    @emit Constants.stores.CARD_RATED

  saveComment: (comment) ->
    console.log comment
    comment

  saveStatusAck: ->
    @emit Constants.stores.PLAY_CONTINUED

  savePlay: (cardID) ->
    console.log "cardID: " + cardID
    @_card = cardID

  getGame: ->
    @_game

  getComments: () ->
    @_comments

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
      play.fetchComments()
    when Constants.actions.CARD_COMMENT
      play.saveComment action.comment
    when Constants.actions.CARD_PICK
      play.savePlay action.cardID
    when Constants.actions.PLAY_CONTINUE
      play.saveStatusAck()
    when Constants.actions.CARD_RATE
      play.saveRating action.rating


module.exports = play
