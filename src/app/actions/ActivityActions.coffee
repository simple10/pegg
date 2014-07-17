AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

ActivityActions =
  load: (page) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_ACTIVITY
      page: page

module.exports = ActivityActions
