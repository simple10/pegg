AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

NavActions =
  selectMenuItem: (pageId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.MENU_SELECT
      pageId: pageId

  selectReviewItem: (cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_SELECT
      cardId: cardId
      peggeeId: peggeeId

module.exports = NavActions
