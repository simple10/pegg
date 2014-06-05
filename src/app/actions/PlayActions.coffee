AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

PlayActions =
  load: (game) ->
    AppDispatcher.handleViewAction
      actionType: Constants.GAME_FETCH
      gameID: game

module.exports = PlayActions
