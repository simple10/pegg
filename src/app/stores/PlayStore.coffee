EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _cardSet: {}
  _card: null
  _comments: null
  _user: UserStore.getUser()

  # TODO: if offline, load from localStorage

  # Tracks state of player in game
  # emits: CARDS_LOADED, UNLOCK_ACHIEVED, or GAME_ERROR
  loadGame: ->
    # TODO: Game flow
    # 1. 10 Pref cards
    # 2. 10 Pegg cards
    # 3. Achievement unlocked
    # Repeat 1-3 until all 5 unlocks achieved
    @_fetchPrefCards @_user, 10, (res) =>
      if res isnt {}
        @_cardSet = res
        @emit Constants.stores.CARDS_LOADED
      else
        @emit Constants.stores.GAME_ERROR
    #@_fetchPeggCards @_user, 10, (res) =>

  _fetchPrefCards: (user, num, cb) ->
    # Gets unanswered preferences: cards the user answers about himself
    cardSet = {}
    Choice = Parse.Object.extend 'Choice'
    Card = Parse.Object.extend 'Card'
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    cardQuery.notContainedIn 'hasPlayed', [user.id]
    cardQuery.find
      success: (cards) =>
        choiceQuery = new Parse.Query Choice
        cCount = 0
        for j in [0..cards.length-1]
          cardSet[cards[j].id] = { pic: user.get('avatar_url'), question: cards[j].get('question'), choices: null }
          choiceQuery.equalTo 'cardId', cards[j].id
          choiceQuery.find
            success: (choices) =>
              cCount++
              pChoices = []
              for i in [0..choices.length-1]
                pChoices.push { id: choices[i].id, text: choices[i].get('text'), image: choices[i].get('image')}
              cardSet[choices[0].get('cardId')].choices = pChoices
              if cCount is cards.length
                cb cardSet
            error: (error) ->
              console.log "Error fetching choices: " + error.code + " " + error.message
              cb cardSet
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message
        cb cardSet

  _fetchPeggCards: (user, num, cb) ->
    # Gets unpegged preferences: cards the user answers about a friend
    cardSet = {}
    Choice = Parse.Object.extend 'Choice'
    Pref = Parse.Object.extend 'Pref'
    prefUser = new Parse.Object 'User'
    prefUser.set 'id', user.id
    prefQuery = new Parse.Query Pref
    prefQuery.limit num
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'choice'
    prefQuery.notEqualTo 'user', prefUser
    prefQuery.notContainedIn 'peggedBy', [user.id]
    prefQuery.find
      success: (prefs) =>
        if prefs.length is 0
          cb cardSet
        else
          choiceQuery = new Parse.Query Choice
          cCount = 0
          for j in [0..prefs.length-1]
            card = prefs[j].get('card')
            peggee = prefs[j].get('user')
            answer = prefs[j].get('choice')
            pic = peggee.get('avatar_url')
            cardSet[card.id] = { peggee: peggee.id, pic: pic, question: card.get('question'), choices: null, answer: answer  }
            choiceQuery.equalTo 'cardId', card.id
            choiceQuery.find
              success: (choices) =>
                cCount++
                pChoices = []
                for i in [0..choices.length-1]
                  pChoices.push { id: choices[i].id, text: choices[i].get('text'), image: choices[i].get('image')}
                cardSet[choices[0].get('cardId')].choices = pChoices
                if cCount is prefs.length
                  cb cardSet
              error: (error) ->
                console.log "Error fetching choices: " + error.code + " " + error.message
                cb cardSet
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message
        cb cardSet

  fetchComments: ->
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

  savePegg: (peggeeId, cardId, choiceId) ->
    #UPDATE Pref table to include current user in peggedBy array
    console.log "card: " + cardId + " choice: " + choiceId
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    user = new Parse.Object 'User'
    user.set 'id', peggeeId
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    prefQuery = new Parse.Query 'Pref'
    prefQuery.equalTo 'card', card
    prefQuery.equalTo 'user', user
    prefQuery.first
      success: (pref) =>
        pref.set 'choice', choice
        pref.addUnique 'peggedBy', @_user.id
        pref.save()
    #INSERT into Pegg table a row with current user's pegg
    @emit Constants.stores.PLAY_SAVED


  savePref: (cardId, choiceId) ->
    #UPDATE Card table to include current user in hasPlayed array
    console.log "card: " + cardId + " choice: " + choiceId
    cardQuery = new Parse.Query 'Card'
    cardQuery.equalTo 'objectId', cardId
    cardQuery.first
      success: (card) =>
        card.addUnique 'hasPlayed', @_user.id
        card.save()
    #INSERT into Pref table a row with user's choice
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    user = new Parse.Object 'User'
    user.set 'id', @_user.id
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    newPref = new Parse.Object 'Pref'
    newPref.set 'choice', choice
    newPref.set 'card', card
    newPref.set 'user', user
    newPref.save()
    @emit Constants.stores.PLAY_SAVED

  saveRating: (rating) ->
    console.log "rating: " + rating
      #TODO: send data to Parse
    if @_card is "qZxzk3ipSd"
      @emit Constants.stores.UNLOCK_ACHIEVED
    @emit Constants.stores.CARD_RATED

  saveComment: (comment) ->
    comment

  saveStatusAck: ->
    @emit Constants.stores.PLAY_CONTINUED

  savePlay: (cardID) ->
    console.log "cardID: " + cardID
    @_card = cardID

  getCards: ->
    @_cardSet

  getComments: () ->
    @_comments

play = new PlayStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.GAME_LOAD
      play.loadGame()
    when Constants.actions.PEGG_SUBMIT
      play.savePegg action.peggee, action.card, action.choice
      play.fetchComments()
    when Constants.actions.PREF_SUBMIT
      play.savePref action.card, action.choice
    when Constants.actions.CARD_COMMENT
      play.saveComment action.comment
    when Constants.actions.CARD_PASS
      play.savePass action.card
    when Constants.actions.PLAY_CONTINUE
      play.saveStatusAck()
    when Constants.actions.CARD_RATE
      play.saveRating action.rating


module.exports = play
