AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

ReviewActions =
  load: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_CARD
      card: cardId
      peggee: peggeeId
      referrer: referrer

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_COMMENT
      comment: comment

module.exports = ReviewActions
