AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

NavActions =
  login: (referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOGIN
      referrer: referrer

  selectMenuItem: (pageId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.MENU_SELECT
      pageId: pageId

  selectSingleCardItem: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_SELECT
      cardId: cardId
      peggeeId: peggeeId
      referrer: referrer

  logout: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOGOUT

module.exports = NavActions
