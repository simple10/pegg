EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class ReviewStore extends EventEmitter
  _card: null
  _comments: []
  _message: ''

  _loadCard: (cardId, peggeeId) ->
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

  getCard: ->
    @_card

  getComments: ->
    @_comments

  getMessage: ->
    @_message

review = new ReviewStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  switch action.actionType
    when Constants.actions.LOAD_CARD
      review._loadCard action.card, action.peggee
      review._loadComments action.card, action.peggee

module.exports = review
