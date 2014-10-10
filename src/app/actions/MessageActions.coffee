AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

MessageActions =
  show: (type) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SHOW_MESSAGE
      type: type

  loading: (context) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOADING_START
      context: context

  doneLoading: (context) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOADING_DONE
      context: context

module.exports = MessageActions
