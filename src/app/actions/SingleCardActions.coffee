AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

SingleCardActions =
  load: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_CARD
      card: cardId
      peggee: peggeeId
      referrer: referrer

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.REVIEW_COMMENT
      comment: comment

module.exports = SingleCardActions
