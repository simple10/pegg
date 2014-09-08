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
  _peggeeId: null

  _setReferrer: (path) ->
    @_referrer = path

  _fetchCard: (cardId, peggeeId) ->
    @_loggedIn = UserStore.getLoggedIn()
    @_userId = UserStore.getUser().id if @_loggedIn

    # logged in user is peggee if no peggee specified
    if @_loggedIn and not peggeeId?
      @_peggeeId = @_userId
    else
      @_peggeeId = peggeeId

    DB.getCard(cardId, (card) =>
      @_card = card

      # determine whether the peggee has preffed the card
      @_hasPreffed = false
      if @_card? and @_card.hasPreffed? and @_loggedIn
        @_hasPreffed = _.contains(@_card.hasPreffed, @_peggeeId)

      if @_hasPreffed
        @_fetchPrefCard()
      else
        @_setCardState()
    )

  _fetchPrefCard: () =>
    console.log "_fetchPrefCard :: card: ", @_card
    console.log "_fetchPrefCard :: peggeeId: ", @_peggeeId
    DB.getPrefCard(@_card.id, @_peggeeId, (prefCard) =>
      @_card = prefCard

      # determine whether the logged in user has pegged the peggee's card
      @_hasPegged = false
      if @_card? and @_card.hasPegged? and @_loggedIn
        @_hasPegged = _.contains(@_card.hasPegged, @_userId)

      @_setCardState()
    )

  _setCardState: () =>
    # display different card states depending on:
    #   - whether user is logged in
    #   - whether the card is public
    #   - whether user has preffed the card
    #   - whether user has pegged peggee
    #   - whether there's a peggee

    debugger

    # scenario 1:
    #   You're logged in and you go to a card. You’ve preffed the card. You see your answer.
    if @_loggedIn and @_card? and @_peggeeId is @_userId and @_hasPreffed
      @_doReview()

    # scenario 2:
    #   You’re logged in and you go to a card you can see. You have not preffed the card. You pref the card.
    else if @_loggedIn and @_card? and @_peggeeId is @_userId and not @_hasPreffed
      @_doPref()

    # scenario 3:
    #   You’re logged in and you go to your friend's card. You've pegged them. You see their answer.
    else if @_loggedIn and @_card? and @_hasPegged
      @_doReview()

    # scenario 4:
    #   You’re logged in and you go to your friend's card. You haven’t pegged them. You pegg them first, then see their answer.
    else if @_loggedIn and @_card? and not @_hasPegged
      @_doPegg()

    # scenario 5:
    #   You’re logged in and you go to a non-friend’s card. The card is not public. You see "Sorry, this card isn't available. You're
    #   probably not friends with the card's owner, and they have not shared it publicly."
    else if @_loggedIn and @_peggeeId? and not @_card?
      @_doDeny()

    # scenario 6:
    #   You’re not logged in, and you go to a peggee’s card. The card is public. You can pegg the card and see the answer image. Clicking
    #   “continue playing” button or leaving a comment asks you to login, then you proceed.
    else if not @_loggedIn and @_card? and @_peggeeId?
      @_doPegg()

    # scenario 7:
    #   You’re not logged in, and you go to a peggee’s card. The card is not public. You can’t see the card. You must log in. Go to
    #   scenario 3.
    else if not @_loggedIn and @_peggeeId? and not @_card?
      @_doRequireLogin()

    # scenario 8:
    #   You’re not logged in, and you go to a public card with no peggeeId. You pref the card. Card flips and shows answer image. XXX
    #   actions like share with friends, save your answer, continue playing. User logs in, does that.
    else if not @_loggedIn and @_card? and not @_peggeeId?
      @_doPref()

    else
      #XXX default ???

  _doPegg: () ->
    console.log "SingleCardStore :: _doPegg called"
    @_card.type = 'play'
    @_fetchChoices()
    @emit Constants.stores.CARD_CHANGE

  _doPref: () ->
    console.log "SingleCardStore :: _doPref called"
    @_card.type = 'play'
    @_card.pic = UserStore.getAvatar()
    @_fetchChoices()
    @emit Constants.stores.CARD_CHANGE

  _doReview: () ->
    console.log "SingleCardStore :: _doReview called"
    @_card.type = 'review'
    @emit Constants.stores.CARD_CHANGE

  _doDeny: () ->
    console.log "SingleCardStore :: _doDeny called"

  _doRequireLogin: () ->
    console.log "SingleCardStore :: _doRequireLogin called"

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
    console.log "review comment: #{comment}  peggee: #{@_peggeeId}  user: #{UserStore.getUser().id}  card: #{@_card.id}"
    DB.saveComment(
      comment
      @_card.id
      @_peggeeId
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
      singleCard._fetchComments action.card, action.peggee if action.peggee?
    when Constants.actions.SINGLE_CARD_COMMENT
      singleCard._comment action.comment
    when Constants.actions.SINGLE_CARD_PLUG
      singleCard._plug action.card, action.url
    when Constants.actions.SINGLE_CARD_PEGG
      singleCard._pegg action.peggee, action.card, action.choice, action.answer
    when Constants.actions.SINGLE_CARD_PREF
      singleCard._pref action.card, action.choice, action.plug


module.exports = singleCard
