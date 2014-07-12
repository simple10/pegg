EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'

Comment = Parse.Object.extend 'Comment'

GameState = require 'stores/helpers/GameState'
MessageState = require 'stores/helpers/MessageState'

class PlayStore extends EventHandler
  _game: null
  _message: null
  _comments: []

#  constructor: () ->
#    @init GameFlow

  _loadGame: (gameFlow) ->
    @_game = new GameState gameFlow
    @_game.pipe @

  _loadScript: (script) ->
    @_message = new MessageState script


  ## Load set of cards
  # emits:
  #   PLAY_CHANGE
  _nextStage: ->
    @_game.loadNextStage()


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
    when Constants.actions.PRELOAD_COMMENTS
      play._fetchComments action.card, action.peggee
    when Constants.actions.NEXT_CARD
      play._fetchComments action.card, action.peggee
    when Constants.actions.CARD_COMMENT
      play._saveComment action.comment
    when Constants.actions.CARD_PASS
      play._savePass action.cardId
    when Constants.actions.NEXT_STAGE
      play._nextStage()
    when Constants.actions.CARD_RATE
      play._saveRating action.rating



module.exports = play
