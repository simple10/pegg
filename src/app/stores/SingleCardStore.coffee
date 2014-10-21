DB = require 'stores/helpers/ParseBackend'
Parse = require 'Parse'
_ = Parse._

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
CardStore = require('stores/CardStore').class
Constants = require 'constants/PeggConstants'
MessageActions = require 'actions/MessageActions'
UserStore = require 'stores/UserStore'

class SingleCardStore extends CardStore
  _card: null
  _referrer: null
  _peggeeId: null
  _hasPreffed: null
  _loggedIn: null
  _userId: null

  _setReferrer: (path) ->
    @_referrer = path

  _fetchCard: (cardId, peggeeId) ->
    MessageActions.loading 'card'
    @_loggedIn = UserStore.getLoggedIn()
    @_userId = UserStore.getUser().id if @_loggedIn

    # logged in user is peggee if no peggee specified
    if @_loggedIn and not peggeeId?
      @_peggeeId = @_userId
    else
      @_peggeeId = peggeeId

    DB.getCard cardId
      .fail @_failHandler
      .then (card) =>
        @_card = card

        # determine whether the peggee has preffed the card
        @_hasPreffed = false
        if @_card? and @_card.hasPreffed?
          @_hasPreffed = _.contains(@_card.hasPreffed, @_peggeeId)

        if @_hasPreffed
          @_fetchPrefCard()
        else
          @_setCardState()

  _fetchPrefCard: () =>
    # console.log "_fetchPrefCard :: card: ", @_card
    # console.log "_fetchPrefCard :: peggeeId: ", @_peggeeId
    DB.getPrefCard @_card.id, @_peggeeId
      .then (prefCard) =>
        @_card = prefCard

        # determine whether the logged in user has pegged the peggee's card
        @_hasPegged = false
        if @_card? and @_card.hasPegged? and @_loggedIn
          @_hasPegged = _.contains(@_card.hasPegged, @_userId)

        @_setCardState()

  _setCardState: () =>
    # display different card states depending on:
    #   - whether user is logged in
    #   - whether the card is public
    #   - whether user has preffed the card
    #   - whether user has pegged peggee
    #   - whether there's a peggee

    #   You're logged in and you go to a card. You’ve preffed the card. You see your answer.
    if @_loggedIn and @_card? and @_peggeeId is @_userId and @_hasPreffed
      @_doReview()

    #   You’re logged in and you go to a card you can see. You have not preffed the card. You pref the card.
    else if @_loggedIn and @_card? and @_peggeeId is @_userId and not @_hasPreffed
      @_doPref()

    #   You’re logged in and you go to your friend's card. You've pegged them. You see their answer.
    else if @_loggedIn and @_card? and @_hasPegged
      @_doReview()

    #   You’re logged in and you go to a peggee's card that you can't see. Access denied.
    else if @_loggedIn and @_card? and @_peggeeId and not @_hasPreffed
      @_doDeny()

    #   You’re logged in and you go to your friend's card. You haven’t pegged them. You pegg them first, then see their answer.
    else if @_loggedIn and @_card? and not @_hasPegged
      @_doPegg()

    #   You’re logged in and you go to a non-friend’s card. The card is not public. Access denied.
    else if @_loggedIn and @_peggeeId? and not @_card?
      @_doDeny()

    #   You’re not logged in, and you go to a peggee’s card. The card is public. You can pegg the card and see the answer image. Clicking
    #   “continue playing” button or leaving a comment asks you to login, then you proceed.
    else if not @_loggedIn and @_card? and @_peggeeId?
      @_doPegg()

    #   You’re not logged in, and you go to a peggee’s card. The card is not public. You can’t see the card. You must log in. Go to
    #   scenario 3.
    else if not @_loggedIn and @_peggeeId? and not @_card?
      @_doRequireLogin()

    #   You’re not logged in, and you go to a card. The card is not public. You can’t see the card. You must log in.
    else if not @_loggedIn and not @_card?
      @_doRequireLogin()

    #   You’re not logged in, and you go to a public card with no peggeeId. You pref the card. Card flips and shows answer image. XXX
    #   actions like share with friends, save your answer, continue playing. User logs in, does that.
    else if not @_loggedIn and @_card? and not @_peggeeId?
      @_doPref()

    else
      @_doDeny()

  _doPegg: () ->
    console.log "SingleCardStore :: _doPegg called"
    @_card.type = 'play'
    cards = {}
    cards[@_card.id] = @_card
    @_loadAncillaryDatums(cards)
      .then =>
        MessageActions.doneLoading 'card'
        @emit Constants.stores.CARD_CHANGE

  _doPref: () ->
    console.log "SingleCardStore :: _doPref called"
    @_card.type = 'play'
    @_card.pic = UserStore.getAvatar()
    cards = {}
    cards[@_card.id] = @_card
    @_loadAncillaryDatums(cards)
      .then =>
        MessageActions.doneLoading 'card'
        @emit Constants.stores.CARD_CHANGE

  _doReview: () ->
    console.log "SingleCardStore :: _doReview called"
    @_card.type = 'review'
    MessageActions.doneLoading 'card'
    @emit Constants.stores.CARD_CHANGE

  _doDeny: () ->
    console.log "SingleCardStore :: _doDeny called"
    @_card = {
      question: "Ruh roh!<br/><br/>Either this card doesn't exist, or you don't have access to it."
      pic: '/images/access_denied_icon.jpg'
      answer:
        plug: '/images/access_denied_plug.jpg'
      type: 'deny'
    }
    MessageActions.doneLoading 'card'
    @emit Constants.stores.CARD_CHANGE

  _doRequireLogin: () ->
    console.log "SingleCardStore :: _doRequireLogin called"
    MessageActions.doneLoading 'card'
    @emit Constants.stores.REQUIRE_LOGIN

  _pegg: ->
    super(arguments...)
    @_card.answered = true

  _pref: ->
    super(arguments...)
    @_card.answered = true

  getCard: ->
    @_card

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


module.exports = singleCard
