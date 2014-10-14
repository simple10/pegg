AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

SingleCardActions =
  load: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_LOAD
      card: cardId
      peggee: peggeeId
      referrer: referrer

module.exports = SingleCardActions
