AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

ReviewActions =
  load: (cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_CARD
      card: cardId
      peggee: peggeeId

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_COMMENT
      comment: comment

module.exports = ReviewActions
