AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

NavActions =
  login: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOGIN

  selectMenuItem: (pageId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.MENU_SELECT
      pageId: pageId

  loadLink: (cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_LINK
      cardId: cardId
      peggeeId: peggeeId

  selectReviewItem: (cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_SELECT
      cardId: cardId
      peggeeId: peggeeId

  logout: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOGOUT

module.exports = NavActions
