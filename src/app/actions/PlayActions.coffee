AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

PeggBoxActions =
  load: (page) ->
    AppDispatcher.handleViewAction
      actionType: Constants.PEGGBOX_FETCH
      page: page

module.exports = PeggBoxActions
