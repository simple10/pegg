EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class SingleCardStore extends EventEmitter
  _card: null
  _comments: []
  _message: ''
  _referrer: ''

  _setReferrer: (path) ->
    @_referrer = path

  _loadCard: (cardId, peggeeId) ->
    @_peggee = peggeeId
    DB.getCard(cardId, peggeeId, (results) =>
      if results
        @_card = results
        @emit Constants.stores.CARD_CHANGE
    )

  _loadComments: (cardId, peggeeId) ->
    DB.getComments(cardId, peggeeId, (res) =>
      if res?
        @_comments = res
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

  getCard: ->
    @_card

  getComments: ->
    @_comments

  getMessage: ->
    @_message

  getReferrer: ->
    @_referrer

review = new SingleCardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  switch action.actionType
    when Constants.actions.LOAD_CARD
      review._setReferrer action.referrer
      review._loadCard action.card, action.peggee
      review._loadComments action.card, action.peggee
    when Constants.actions.REVIEW_COMMENT
      review._comment action.comment


module.exports = review
