AppDispatcher = require 'dispatchers/AppDispatcher'

MenuActions =
  selectMenuItem: (pageID) ->
    AppDispatcher.handleViewAction
      actionType: Pegg.MENU_SELECT
      pageID: pageID

module.exports = MenuActions
