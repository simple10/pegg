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
  _cardIndex: []
  _cardPosition: 0

  _loadGame: (flow) ->
    @_game = new GameState flow
    @_game.pipe @

  _loadScript: (script) ->
    @_message = new MessageState script

  _nextStage: ->
    @_game.loadNextStage()

  _nextCard: ->
    if @_cardPosition is @_cardIndex.length - 1
      # TODO: load Status
      @emit Constants.stores.STATUS_CHANGE
      @_cardPosition = 0
    else
      @_cardPosition++
      cardId = @_cardIndex[@_cardPosition]
      cards = @_game.getCards()
      card = cards[cardId]
      @_fetchComments cardId, if card.peggee? then card.peggee else UserStore.getUser().id

  _fetchComments: (cardId, peggeeId) ->
    @_peggee = peggeeId
    @_card = cardId
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
    # UPDATE Pref table to include current user in peggedBy array
    console.log "peggee: #{peggeeId}  card: #{cardId}  choice: #{choiceId} "
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    prefQuery = new Parse.Query 'Pref'
    prefQuery.equalTo 'card', card
    prefQuery.equalTo 'user', peggee
    prefQuery.first
      success: (pref) =>
        pref.addUnique 'peggedBy', UserStore.getUser().id
        #pref.set 'peggedBy', null
        pref.save()

    # INSERT into Pegg table a row with current user's pegg
    user = UserStore.getUser()
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    pegger = new Parse.Object 'User'
    pegger.set 'id',  user.id
    newPeggAcl = new Parse.ACL user
    newPeggAcl.setRoleReadAccess "#{user.id}_Friends", true
    peggee = new Parse.Object 'User'
    peggee.set 'id',  peggeeId
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    answer = new Parse.Object 'Answer'
    answer.set 'id', answerId
    newPegg = new Parse.Object 'Pegg'
    newPegg.set 'guess', choice
    newPegg.set 'answer', answer
    newPegg.set 'card', card
    newPegg.set 'user', pegger
    newPegg.set 'ACL', newPeggAcl
    newPegg.set 'peggee', peggee
    newPegg.save()
    if choiceId is answerId
      @emit Constants.stores.CARD_WIN
    else
      @emit Constants.stores.CARD_FAIL

  _savePref: (cardId, choiceId) ->
    user = UserStore.getUser()
    # UPDATE Card table to include current user in hasPlayed array
    console.log "card: " + cardId + " choice: " + choiceId
    cardQuery = new Parse.Query 'Card'
    cardQuery.equalTo 'objectId', cardId
    cardQuery.first
      success: (card) =>
        card.addUnique 'hasPlayed', user.id
        card.save()

    # INSERT into Pref table a row with user's choice
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    preffer = new Parse.Object 'User'
    preffer.set 'id',  user.id
    newPrefAcl = new Parse.ACL user
    newPrefAcl.setRoleReadAccess "#{user.id}_Friends", true
    answer = new Parse.Object 'Choice'
    answer.set 'id', choiceId
    newPref = new Parse.Object 'Pref'
    newPref.set 'answer', answer
    newPref.set 'card', card
    newPref.set 'user', preffer
    newPref.set 'ACL', newPrefAcl
    newPref.save()
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
    user = UserStore.getUser()
    peggee = new Parse.Object 'User'
    peggee.set 'id', @_peggee
    newComment = new Parse.Object 'Comment'
    newCommentAcl = new Parse.ACL user
    newCommentAcl.setRoleReadAccess "#{user.id}_Friends", true
    newComment.set 'peggee', peggee
    newComment.set 'card', card
    newComment.set 'text', comment
    newComment.set 'author', user.id
    newComment.set 'userImg', UserStore.getAvatar 'type=square'
    newComment.set 'ACL', newCommentAcl
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
    cards = @_game.getCards()
    i = 0
    for own cardId of cards
      @_cardIndex[i] = cardId
      i++
    cards

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
    when Constants.actions.LOAD_GAME
      play._loadGame action.flow
      play._loadScript action.script
      play._nextStage()
    when Constants.actions.PEGG_SUBMIT
      play._savePegg action.peggee, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      play._savePref action.card, action.choice
    when Constants.actions.NEXT_CARD
      play._nextCard()
    when Constants.actions.CARD_COMMENT
      play._saveComment action.comment
    when Constants.actions.CARD_PASS
      play._savePass action.card
    when Constants.actions.NEXT_STAGE
      play._nextStage()
    when Constants.actions.CARD_RATE
      play._saveRating action.rating



module.exports = play
