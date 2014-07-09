EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'


Choice = Parse.Object.extend 'Choice'
Card = Parse.Object.extend 'Card'
Pref = Parse.Object.extend 'Pref'
Choice = Parse.Object.extend 'Choice'
Comment = Parse.Object.extend 'Comment'


class PlayStore extends EventEmitter
  _cardSet: {}
  _card: null
  _comments: null
  _mode: Constants.stores.PLAY_PEGGS
  _peggee: null
  _message: null


  ## Load set of cards
  # emits:
  #   PLAY_CHANGE
  _loadGame: ->
    if @_mode is Constants.stores.PLAY_PREFS
      @_fetchPeggCards 5
      @_mode = Constants.stores.PLAY_PEGGS
    else
      @_fetchPrefCards 1
      @_mode = Constants.stores.PLAY_PREFS
    @emit Constants.stores.PLAY_CHANGE


  _fetchPrefCards: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @_cardSet = {}
    user = UserStore.getUser()
    cardQuery = new Parse.Query Card
    cardQuery.limit num
#    cardQuery.notContainedIn 'hasPlayed', [user.id]
    cardQuery.skip Math.floor(Math.random() * 180)
    cardQuery.find
      success: (cards) =>
        for card in cards
          @_cardSet[card.id] = {
            firstName: user.get 'first_name'
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
    prefUser = new Parse.Object 'User'
    prefUser.set 'id', user.id
    prefQuery = new Parse.Query Pref
    prefQuery.limit num
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'choice'
    prefQuery.notEqualTo 'user', prefUser
    #prefQuery.notContainedIn 'peggedBy', [user.id]
    prefQuery.skip Math.floor(Math.random() * 280)
    prefQuery.find
      success: (prefs) =>
        for pref in prefs
          card = pref.get 'card'
          peggee = pref.get 'user'
          @_cardSet[card.id] = {
            peggee: peggee.id
            firstName: peggee.get 'first_name'
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
    query = new Parse.Query Comment
    card = new Parse.Object 'Card'
    card.set 'id', @_card
    peggee = new Parse.Object 'User'
    peggee.set 'id', @_peggee
    query.equalTo 'peggee', peggee
    query.equalTo 'card', card
    query.include 'author'
    query.find
      success: (results) =>
        @_comments = results
        @emit Constants.stores.COMMENTS_CHANGE
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"

  _fetchMessage: (type) ->
    fails = [
      'Almost... but not quite.<br/>Try again.'
      'You\'re awesome!<br/>But that guess wasn\'t.'
      'Don\'t worry,<br/>that fail is safe with us.'
      'Hmm... try again.<br/>You got this.'
    ]
    wins = [
      'Hooray!! You rule!'
      'Crushin\' it!'
      'Way to be a decent friend.'
      'Friend points earned!'
      'Dude!<br/>Way to not suck at this.'
    ]
    prefs = [
      'Preference saved.'
      'So that\'s what you\'re into.<br/>Interesting...'
      'Noted. Carry on.'
      'Your friends will be relieved.'
      'Confucius say:<br/>preferences are like buttholes.'
    ]
    if type is 'fail'
      return fails[Math.floor(Math.random() * fails.length)]
    else if type is 'win'
      return wins[Math.floor(Math.random() * wins.length)]
    else if type is 'pref'
      return prefs[Math.floor(Math.random() * prefs.length)]

  _savePegg: (peggeeId, cardId, choiceId, answerId) ->
    @_peggee = peggeeId
    @_card = cardId

    #UPDATE Pref table to include current user in peggers array
    console.log "peggee: #{peggeeId}  card: #{cardId}  choice: #{choiceId} "
#    card = new Parse.Object 'Card'
#    card.set 'id', @_card
#    peggee = new Parse.Object 'User'
#    peggee.set 'id', @_peggee
#    choice = new Parse.Object 'Choice'
#    choice.set 'id', choiceId
#    prefQuery = new Parse.Query 'Pref'
#    prefQuery.equalTo 'card', card
#    prefQuery.equalTo 'user', peggee
#    prefQuery.first
#      success: (pref) =>
#        pref.set 'choice', choice
#        pref.addUnique 'peggedBy', UserStore.getUser().id
#        pref.save()
    #TODO: INSERT into Pegg table a row with current user's pegg
    if choiceId is answerId
      @_message = @_fetchMessage 'win'
      @emit Constants.stores.CARD_WIN
    else
      @_message = @_fetchMessage 'fail'
      @emit Constants.stores.CARD_FAIL


  _savePref: (cardId, choiceId) ->
    @_peggee = UserStore.getUser().id
    @_card = cardId

    #UPDATE Card table to include current user in hasPlayed array
    console.log "card: " + cardId + " choice: " + choiceId
#    cardQuery = new Parse.Query 'Card'
#    cardQuery.equalTo 'objectId', cardId
#    cardQuery.first
#      success: (card) =>
#        card.addUnique 'hasPlayed', @_peggee
#        card.save()
    #INSERT into Pref table a row with user's choice
#    card = new Parse.Object 'Card'
#    card.set 'id', cardId
#    user = new Parse.Object 'User'
#    user.set 'id', @_peggee
#    choice = new Parse.Object 'Choice'
#    choice.set 'id', choiceId
#    newPref = new Parse.Object 'Pref'
#    newPref.set 'choice', choice
#    newPref.set 'card', card
#    newPref.set 'user', user
#    newPref.save()
    @_message = @_fetchMessage 'pref'
    @emit Constants.stores.PREF_SAVED

  _saveRating: (rating) ->
    console.log "rating: #{rating}"
    #TODO: send data to Parse
    @emit Constants.stores.CARD_RATED

  _saveComment: (comment) ->
    console.log "comment: #{comment}  peggee: #{@_peggee}  card: #{@_card}"
    card = new Parse.Object 'Card'
    card.set 'id', @_card
    user = new Parse.Object 'User'
    user.set 'id', UserStore.getUser().id
    peggee = new Parse.Object 'User'
    peggee.set 'id', @_peggee
    newComment = new Parse.Object 'Comment'
    newComment.set 'peggee', peggee
    newComment.set 'card', card
    newComment.set 'text', comment
    newComment.set 'author', user
    newComment.set 'userImg', UserStore.getAvatar 'type=square'
    newComment.save()
    @_comments.push newComment
    @emit Constants.stores.COMMENTS_CHANGE

  _saveStatusAck: ->
    @emit Constants.stores.PLAY_CHANGE

  _savePlay: (cardId) ->
    console.log "cardID: " + cardId
    #@_card = cardId

  _savePass: (cardId) ->
    console.log "cardID: " + cardId

  getCards: ->
    @_cardSet

  getComments: ->
    @_comments

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getPlayState: ->
    if @_mode is Constants.stores.PLAY_PREFS and @_cardSet = {}
      Constants.stores.NO_PREFS_REMAINING
    else if @_mode is Constants.stores.PLAY_PEGGS and @_cardSet = {}
      Constants.stores.NO_PEGGS_REMAINING
    else
      @_mode

  getMessage: ->
    @_message

play = new PlayStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.SET_LOAD
      play._loadGame()
    when Constants.actions.PEGG_SUBMIT
      play._savePegg action.peggee, action.card, action.choice, action.answer
      play._fetchComments()
    when Constants.actions.PREF_SUBMIT
      play._savePref action.card, action.choice
      play._fetchComments()
    when Constants.actions.CARD_COMMENT
      play._saveComment action.comment
    when Constants.actions.CARD_PASS
      play._savePass action.cardId
    when Constants.actions.PLAY_CONTINUE
      play._saveStatusAck()
    when Constants.actions.CARD_RATE
      play._saveRating action.rating


module.exports = play
