EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'
GameState = require 'stores/helpers/GameState'
MessageState = require 'stores/helpers/MessageState'

class PlayStore extends EventHandler
  _card: null
  _game: null
  _message: null
  _comments: []
  _cardIndex: []
  _cardPosition: 0
  _fail: 0
  _peggee: ''
  _cardId: ''

  _loadGame: (flow, script) ->
    @_game = new GameState flow
    @_game.pipe @
    @_message = new MessageState script
    @_nextStage()

  _loadCard: (position) ->
    cardId = @_cardIndex[position]
    # cards = @_game.getCards()
    @_cards = @_game.getCards()
    card = @_cards[cardId]
    @_peggee = if card.peggee? then card.peggee else UserStore.getUser().id
    @_cardId = cardId
    DB.getComments(@_cardId, @_peggee, (res) =>
      if res?
        @_comments = res
        @emit Constants.stores.COMMENTS_CHANGE
    )

  _nextStage: ->
    @_game.loadNextStage()

  _nextCard: ->
    if @_cardPosition is @_cardIndex.length - 1
      @_game.loadStatus()
      @_cardPosition = 0
    else
      @_cardPosition++
      @_loadCard @_cardPosition

  _prevCard: ->
    @_cardPosition--
    @_loadCard @_cardPosition

  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId
    userId = UserStore.getUser().id

    # save answered status
    console.log '_pegg', cardId
    @_cards[cardId].answered = true

    # Save pegg
    DB.savePegg(peggeeId, cardId, choiceId, answerId, userId, (res)->
      if res?
        console.log res
    )
    # Save points
    if choiceId is answerId
      points = 10 - 3 * @_fail
      DB.savePoints(userId, peggeeId, points, (res)->
        if res?
          console.log res
      )
      @_fail = 0
      @emit Constants.stores.CARD_WIN
    else
      @_fail++
      @emit Constants.stores.CARD_FAIL

  _pref: (cardId, choiceId) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId
    userId = UserStore.getUser().id

    # save answered status
    @_cards[cardId].answered = true

    DB.savePref(cardId, choiceId, userId, (res)=>
      if res?
        console.log res
    )

    DB.savePrefCount(cardId, choiceId, (res)=>
      if res?
        console.log res
      @emit Constants.stores.PREF_SAVED
    )

  _rate: (rating) ->
    console.log "rating: #{rating}"
    #TODO: send data to Parse
    @emit Constants.stores.CARD_RATED

  _comment: (comment) ->
    console.log "comment: #{comment}  peggee: #{@_peggee}  card: #{@_cardId}"
    DB.saveComment(
      comment
      @_cardId
      @_peggee
      UserStore.getUser().id
      UserStore.getAvatar 'type=square'
      (res) =>
        @_comments.unshift res
        @emit Constants.stores.COMMENTS_CHANGE
    )

  _statusAck: ->
    @emit Constants.stores.PLAY_CHANGE

  _pass: (cardId) ->
    console.log "cardID: " + cardId

  getCards: ->
    cards = @_game.getCards()
    # Build index of card ids
    i = 0
    for own cardId of cards
      @_cardIndex[i] = cardId
      i++
    # Load the first card in set
    @_loadCard 0
    cards

  getStatus: ->
    @_game.getStatus()

  getComments: ->
    @_comments

  getChoices: (cardId) ->
    @_game.getChoices(cardId)

  getMessage: (type) ->
    @_message.getMessage(type)

  getCurrentCardIsAnswered: ->
    console.log 'getCurrentCardAnswerStatus:cardId', @_cardId
    @_cards[@_cardId].answered


play = new PlayStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.LOAD_GAME
      play._loadGame action.flow, action.script
    when Constants.actions.PEGG_SUBMIT
      play._pegg action.peggee, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      play._pref action.card, action.choice
    when Constants.actions.NEXT_CARD
      play._nextCard()
    when Constants.actions.PREV_CARD
      play._prevCard()
    when Constants.actions.CARD_COMMENT
      play._comment action.comment
    when Constants.actions.CARD_PASS
      play._pass action.card
    when Constants.actions.NEXT_STAGE
      play._nextStage()
    when Constants.actions.CARD_RATE
      play._rate action.rating

module.exports = play
