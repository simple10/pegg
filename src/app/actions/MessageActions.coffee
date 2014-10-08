AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

MessageActions =
  show: (type) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SHOW_MESSAGE
      type: type

module.exports = MessageActions
