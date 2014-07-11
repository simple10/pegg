EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'

Choice = Parse.Object.extend 'Choice'
Card = Parse.Object.extend 'Card'
Pref = Parse.Object.extend 'Pref'
Choice = Parse.Object.extend 'Choice'
Comment = Parse.Object.extend 'Comment'


class PlayStore extends EventHandler
  _game: null
  _message: null
  _comments: null

#  constructor: () ->
#    @init GameFlow

  _loadGame: (gameFlow) ->
    @_game = new Game gameFlow

  _loadScript: (script) ->
    @_message = new Message script


  ## Load set of cards
  # emits:
  #   PLAY_CHANGE
  _nextStage: ->
    @_game.loadStage()


  _fetchComments: (cardId, peggeeId) ->
    query = new Parse.Query Comment
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    query.equalTo 'peggee', peggee
    query.equalTo 'card', card
    query.include 'author'
    query.find
      success: (results) =>
        @_comments = results
        @emit Constants.stores.COMMENTS_CHANGE
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"

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
      @emit Constants.stores.CARD_WIN
    else
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
    @_game.getCards()

  getStatus: ->
    @_game.getStatus()

  getComments: ->
    @_comments

  getChoices: (cardId) ->
    @_game.getChoices(cardId)

  getMessage: (type) ->
    @_message.getMessage(type)

play = new PlayStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.SET_LOAD #TODO STAGE_COMPLETE
      play._loadGame action.flow
      play._loadScript action.script
      play._nextStage()
    when Constants.actions.PEGG_SUBMIT
      play._savePegg action.peggee, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      play._savePref action.card, action.choice
    when Constants.actions.NEXT_CARD
      play._fetchComments action.card, action.peggee
    when Constants.actions.CARD_COMMENT
      play._saveComment action.comment
    when Constants.actions.CARD_PASS
      play._savePass action.cardId
    when Constants.actions.PLAY_CONTINUE
      play._saveStatusAck()
    when Constants.actions.CARD_RATE
      play._saveRating action.rating


class Game extends EventEmitter
  constructor: (data) ->
    @_stages = for stageData in data
      new Stage stageData

  loadStage: ->
    if @_currentStage? then @_currentStage++  else @_currentStage = 0
    @_stage = @_stages[@_currentStage]
    @_stage.load()

  getCards: ->
    @_stage.cardSet

  getChoices: (cardId) ->
    # @_cardSet[cardId].choices

class Stage extends EventEmitter
  cardSet = {}
  status = null

  constructor: (data) ->
    @_part = data[0]   # later we will support multiple parts

  load: ->
    if @_part.type is 'pref'
      @_fetchPrefCards @_part.size
    else if @_part.type is 'pegg'
      @_fetchPeggCards @_part.size
    else
      raise "unexpected part type: #{@_part.type}"

  _fetchPrefCards: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @cardSet  = {}
    user = UserStore.getUser()
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    #    cardQuery.notContainedIn 'hasPlayed', [user.id]
    cardQuery.skip Math.floor(Math.random() * 180)
    cardQuery.find
      success: (cards) =>
        for card in cards
          @cardSet[card.id] = {
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
    @cardSet = {}
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
          @cardSet[card.id] = {
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

  _fetchChoices: (cardId) =>
    choiceQuery = new Parse.Query Choice
    choiceQuery.equalTo 'cardId', cardId
    choiceQuery.find
      success: (choices) =>
        @cardSet[cardId].choices = []
        for choice in choices
          @cardSet[cardId].choices.push
            id: choice.id
            text: choice.get 'text'
            image: choice.get 'image'
        @emit Constants.stores.CHOICES_CHANGE, cardId
      error: (error) ->
        console.log "Error fetching choices: " + error.code + " " + error.message

class Message
  constructor: (script) ->
    @_script = script
    @_currentMessage = {}

  getMessage: (type) ->
    index = @_currentMessage[type] or 0
    @_currentMessage[type] = index + 1
    @_script[type][index]

module.exports = play
