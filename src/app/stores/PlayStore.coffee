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
    @_cards = @_game.getCards()
    card = @_cards[cardId]
    if card?
      @_peggee = if card.peggee? then card.peggee else UserStore.getUser().id
      @_cardId = cardId
      DB.getComments(@_cardId, @_peggee, (res) =>
        if res?
          @_comments = res
          @emit Constants.stores.COMMENTS_CHANGE
      )
    else
      # TODO: emit no cards to play

  _nextStage: ->
    @_game.loadNextStage()

  _nextCard: ->
    console.log 'playstore nextcard'
    if @_cardPosition is @_cardIndex.length - 1
      @_game.loadStatus()
      @_cardPosition = 0
    else
      @_cardPosition++
      @_loadCard @_cardPosition
      @emit Constants.stores.CARD_CHANGE, @_cardPosition

  _prevCard: ->
    console.log 'playstore prevcard'
    @_cardPosition--
    @_loadCard @_cardPosition
    @emit Constants.stores.CARD_CHANGE, @_cardPosition

  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId
    userId = UserStore.getUser().id

    # save answered status
    @_cards[cardId].answered = true

    # Save pegg
    DB.savePegg(peggeeId, cardId, choiceId, answerId, userId, (res)->
      # TODO: catch save fail
      #if res?
    )
    # Save points
    if choiceId is answerId
      points = 10 - 3 * @_fail
      DB.savePoints(userId, peggeeId, points, (res)->
        # TODO: catch save fail
        #if res?
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
      # TODO: catch save fail
      if res?
        console.log res
    )

    DB.savePrefCount(cardId, choiceId, (res)=>
      if res?
        console.log res
      @emit Constants.stores.PREF_SAVED
    )

  _plug: (cardId, url) ->
    console.log "save Plug: card: " + cardId + " image: " + url
    userId = UserStore.getUser().id

    DB.savePlug(cardId, url, userId, (res)=>
      # TODO: catch save fail
      #if res?
      @emit Constants.stores.PLUG_SAVED
    )

  _rate: (rating) ->
    console.log "rating: #{rating}"
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

  _pass: (cardId) ->
    console.log "cardID: " + cardId

  getCards: ->
    @_cards = @_game.getCards()
    @_cardIndex = []
    # rebuild index of card ids
    i = 0
    for own cardId of @_cards
      @_cardIndex[i] = cardId
      i++
    # Load the first card in set
    @_loadCard 0
    @_cards

  getStatus: ->
    @_game.getStatus()

  getComments: ->
    @_comments

  getChoices: (cardId) ->
    @_game.getChoices(cardId)

  getMessage: (type) ->
    @_message.getMessage(type)

  getCurrentCardIsAnswered: ->
    @_cards[@_cardId].answered

  getCurrentCardsType: =>
    type = 'pref'
    id = @_cardIndex[0]
    if @_cards[id].peggee
      type = 'pegg'
    type



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
    when Constants.actions.PLUG_IMAGE
      play._plug action.card, action.url
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
