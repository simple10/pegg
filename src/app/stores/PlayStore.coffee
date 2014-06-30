EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'


class PlayStore extends EventEmitter
  _cardSet: {}
  _card: null
  _comments: null
  _mode: null
  _peggee: null


  ## Load set of cards
  # emits:
  #   PLAY_CHANGE
  _loadGame: ->
    if @_mode is Constants.stores.PLAY_PREFS
      @_fetchPeggCards 3
      @_mode = Constants.stores.PLAY_PEGGS
    else
      @_fetchPrefCards 1
      @_mode = Constants.stores.PLAY_PREFS
    @emit Constants.stores.PLAY_CHANGE


  _fetchPrefCards: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @_cardSet = {}
    user = UserStore.getUser()
    Choice = Parse.Object.extend 'Choice'
    Card = Parse.Object.extend 'Card'
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    cardQuery.notContainedIn 'hasPlayed', [user.id]
    cardQuery.find
      success: (cards) =>
        for card in cards
          @_cardSet[card.id] = {
            pic: user.get 'avatar_url'
            question: card.get 'question'
            choices: null
          }
          @_fetchChoices(card.id)
        @emit Constants.stores.CARDS_CHANGE
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message


  _fetchPeggCards: (num) ->
    # Gets unpegged preferences: cards the user answers about a friend
    @_cardSet = {}
    user = UserStore.getUser()
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
        for pref in prefs
          card = pref.get 'card'
          peggee = pref.get 'user'
          @_cardSet[card.id] = {
            peggee: peggee.id
            pic: peggee.get 'avatar_url'
            question: card.get 'question'
            choices: null
            answer: pref.get 'choice'
          }
          @_fetchChoices card.id
        @emit Constants.stores.CARDS_CHANGE
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message


  _fetchChoices: (cardId) ->
    Choice = Parse.Object.extend 'Choice'
    choiceQuery = new Parse.Query Choice
    choiceQuery.equalTo 'cardId', cardId
    choiceQuery.find
      success: (choices) =>
        @_cardSet[cardId].choices = []
        for choice in choices
          @_cardSet[cardId].choices.push
            id: choice.id
            text: choice.get 'text'
            image: choice.get 'image'
        @emit Constants.stores.CHOICES_CHANGE, cardId
      error: (error) ->
        console.log "Error fetching choices: " + error.code + " " + error.message


  _fetchComments: ->
    @_comments = [
      { text: 'totally disagree, you woulda picked the girly one.', imageUrl: 'https://graph.facebook.com/4901716/picture?type=square'},
      { text: 'dear oh me oh my this is a comment!', imageUrl: 'https://graph.facebook.com/21303798/picture/?type=square'},
      { text: 'this is the craziest thing ever...', imageUrl: 'https://graph.facebook.com/598877832/picture/?type=square'},
      { text: 'So how would you go about making a half-man, half-monkey type creature?', imageUrl: 'https://graph.facebook.com/4914848/picture?type=square'},
      { text: 'thats some next level shiz!', imageUrl: 'https://graph.facebook.com/21303798/picture/?type=square'},
      { text: 'hmm... not sure what to make of that.', imageUrl: 'https://graph.facebook.com/4914848/picture?type=square'},
    ]
    @emit Constants.stores.COMMENTS_CHANGE
    ###Comments = Parse.Object.extend("Comment")
    query = new Parse.Query(Comments)
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    query.equalTo "peggee", peggee
    query.equalTo "card", card
    query.include "author"
    query.find
      success: (results) =>
        @_comments = results
        @emit Constants.stores.COMMENTS_CHANGE
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message###

  _savePegg: (peggeeId, cardId, choiceId) ->
    #UPDATE Pref table to include current user in peggedBy array
    ###console.log "card: " + cardId + " choice: " + choiceId
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
        pref.addUnique 'peggedBy', UserStore.getUser().id
        pref.save()###
    #INSERT into Pegg table a row with current user's pegg
    @emit Constants.stores.PLAY_SAVED


  _savePref: (cardId, choiceId) ->
    #UPDATE Card table to include current user in hasPlayed array
    ###console.log "card: " + cardId + " choice: " + choiceId
    cardQuery = new Parse.Query 'Card'
    cardQuery.equalTo 'objectId', cardId
    cardQuery.first
      success: (card) =>
        card.addUnique 'hasPlayed', UserStore.getUser().id
        card.save()###
    #INSERT into Pref table a row with user's choice
    ###card = new Parse.Object 'Card'
    card.set 'id', cardId
    user = new Parse.Object 'User'
    user.set 'id', UserStore.getUser().id
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    newPref = new Parse.Object 'Pref'
    newPref.set 'choice', choice
    newPref.set 'card', card
    newPref.set 'user', user
    newPref.save()###
    @emit Constants.stores.PLAY_SAVED

  _saveRating: (rating) ->
    console.log "rating: " + rating
    #TODO: send data to Parse
    @emit Constants.stores.CARD_RATED

  _saveComment: (comment) ->
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

  _saveStatusAck: ->
    @_playState = Constants.stores.PLAY_CONTINUED
    @emit Constants.stores.CHANGE

  _savePlay: (cardId) ->
    console.log "cardID: " + cardId
    #@_card = cardId

  _savePass: (cardId) ->
    console.log "cardID: " + cardId

  getCards: ->
    @_cardSet

  getComments: () ->
    @_comments

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getPlayState: () ->
    if @_mode is Constants.stores.PLAY_PREFS and @_cardSet is {}
        return Constants.stores.NO_PREFS_REMAINING
    else if @_mode is Constants.stores.PLAY_PEGGS and @_cardSet is {}
        return Constants.stores.NO_PEGGS_REMAINING
    @_mode

play = new PlayStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.SET_LOAD
      play._loadGame()
    when Constants.actions.PEGG_SUBMIT
      play._savePegg action.choice
      play._fetchComments()
    when Constants.actions.PREF_SUBMIT
      play._savePref action.card, action.choice
    when Constants.actions.CARD_COMMENT
      play._saveComment action.comment
    when Constants.actions.CARD_PASS
      play._savePass action.cardId
    when Constants.actions.PLAY_CONTINUE
      play._saveStatusAck()
    when Constants.actions.CARD_RATE
      play._saveRating action.rating


module.exports = play
