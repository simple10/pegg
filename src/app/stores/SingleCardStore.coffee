EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'
_ = require('Parse')._


class SingleCardStore extends EventEmitter
  _card: null
  _comments: []
  _message: ''
  _fail: 0
  _referrer: ''

  _setReferrer: (path) ->
    @_referrer = path

  _fetchCard: (cardId, peggeeId) ->
    # do different things depending on:
    #   - whether there's a peggee
    #   - whether user is logged in
    #   - whether user has preffed the card
    #   - whether user has pegged peggee
    #   - whether the card is public

    loggedIn = UserStore.getLoggedIn()

    if peggeeId?
      @_peggee = peggeeId
      DB.getPrefCard(cardId, peggeeId, (card) =>
        if card?
          @_card = card
          hasPegged = if loggedIn then _.contains(card.hasPegged, UserStore.getUser().id) else false
          @_card.type = if hasPegged then 'review' else 'play'
          @_fetchChoices()
          @emit Constants.stores.CARD_CHANGE
      )
    else
      DB.getCard(cardId, (card) =>
        if card?
          @_card = card
          hasPreffed = if loggedIn then _.contains(card.hasPreffed, UserStore.getUser().id) else false
          @_card.type = if hasPreffed then 'review' else 'play'
          @emit Constants.stores.CARD_CHANGE
      )

  _fetchChoices: () ->
    DB.getChoices(@_card.id
      (choices) =>
        for choice in choices
          text = choice.get 'text'
          image = choice.get 'image'
          # only add choices that are not blank
          if text isnt ''
            # image isnt '' and
            @_card.choices.push
              id: choice.id
              text: text
              image: image
        @emit Constants.stores.CHOICES_CHANGE,
          cardId: @_card.id
          choices: @_card.choices
    )

  _fetchComments: (cardId, peggeeId) ->
    DB.getComments(cardId, peggeeId, (comments) =>
      if comments?
        @_comments = comments
        @emit Constants.stores.COMMENTS_CHANGE
    )

  _comment: (comment) ->
    console.log "review comment: #{comment}  peggee: #{@_peggee}  user: #{UserStore.getUser().id}  card: #{@_card.id}"
    DB.saveComment(
      comment
      @_card.id
      @_peggee
      UserStore.getUser().id
      UserStore.getAvatar 'type=square'
      (res) =>
        @_comments.unshift res
        @emit Constants.stores.COMMENTS_CHANGE
    )

  _plug: (cardId, url) ->
    console.log "save Plug: card: " + cardId + " image: " + url
    userId = UserStore.getUser().id

    DB.savePlug(cardId, url, userId, (res)=>
      # TODO: catch save fail
      #if res?
      @emit Constants.stores.PLUG_SAVED
    )

  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId
    userId = UserStore.getUser().id

    # save answered status
    @_card.answered = true

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
      @emit Constants.stores.CARD_WIN, points

    else
      @_fail++
      @emit Constants.stores.CARD_FAIL

  _pref: (cardId, choiceId, plugUrl) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId
    userId = UserStore.getUser().id

    # save answered status
    @_card.answered = true

    DB.savePref(cardId, choiceId, plugUrl, userId, (res)=>
      # TODO: catch save fail
      if res?
        console.log res
    )

    DB.savePrefCount(cardId, choiceId, (res)=>
      if res?
        console.log res
      @emit Constants.stores.PREF_SAVED
    )

  getCard: ->
    @_card

  getComments: ->
    @_comments

  getMessage: ->
    @_message

  getReferrer: ->
    @_referrer

singleCard = new SingleCardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  switch action.actionType
    when Constants.actions.SINGLE_CARD_LOAD
      singleCard._setReferrer action.referrer
      singleCard._fetchCard action.card, action.peggee
      singleCard._fetchComments action.card, action.peggee
    when Constants.actions.SINGLE_CARD_COMMENT
      singleCard._comment action.comment
    when Constants.actions.SINGLE_CARD_PLUG
      singleCard._plug action.card, action.url
    when Constants.actions.SINGLE_CARD_PEGG
      singleCard._pegg action.peggee, action.card, action.choice, action.answer
    when Constants.actions.SINGLE_CARD_PREF
      singleCard._pref action.card, action.choice, action.plug


module.exports = singleCard
