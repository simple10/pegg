AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

WeActions =
  loadInsights: (peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_INSIGHTS
      peggeeId: peggeeId

  loadActivity: (pageId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_ACTIVITY
      pageId: pageId

module.exports = WeActions
