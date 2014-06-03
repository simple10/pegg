AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

MenuActions =
  selectMenuItem: (pageID) ->
    AppDispatcher.handleViewAction
      actionType: Constants.MENU_SELECT
      pageID: pageID

module.exports = MenuActions
