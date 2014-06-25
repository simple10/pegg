EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _game: {}
  _card: null
  _comments: null

  # TODO: if offline, load from localStorage

  fetchGame: (gameID) ->
    # Gets 10 unanswered "Preferences" or cards about the user
    Choice = Parse.Object.extend 'Choice'
    Pref = Parse.Object.extend 'Pref'
    prefQuery = new Parse.Query Pref
    prefQuery.limit 10
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.equalTo 'choice', null
    prefQuery.find
      success: (prefs) =>
        choiceQuery = new Parse.Query Choice
        done = 0
        for j in [0..prefs.length-1]
          card = prefs[j].get('card')
          pic = prefs[j].get('user').get('avatar_url')
          @_game[card.id] = { pic: pic, question: card.get('question'), choices: null }
          choiceQuery.equalTo 'cardId', card.id
          choiceQuery.find
            success: (choices) =>
              pChoices = []
              for i in [0..choices.length-1]
                pChoices.push { id: choices[i].id, text: choices[i].get('text'), image: choices[i].get('image')}
              @_game[choices[0].get('cardId')].choices = pChoices
              if done is prefs.length-1
                @emit Constants.stores.CHANGE
              done++
            error: (error) ->
              console.log "Error fetching choices: " + error.code + " " + error.message
      error: (error) ->
        console.log "Error fethcing cards: " + error.code + " " + error.message
    return

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

  saveAnswer: (cardId, choiceId) ->
    console.log "card: " + cardId + " choice: " + choiceId
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    user = new Parse.Object 'User'
    user.set 'id', 'OtWqilgV3h'
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    prefQuery = new Parse.Query 'Pref'
    prefQuery.equalTo 'card', card
    prefQuery.equalTo 'user', user
    prefQuery.first
      success: (pref) =>
        pref.set 'choice', choice
        pref.save()
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
    #console.log JSON.stringify(@_game)
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
      play.saveAnswer action.pref, action.choice
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
