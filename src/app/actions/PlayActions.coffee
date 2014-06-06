AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

PlayActions =
  load: (game) ->
    AppDispatcher.handleViewAction
      actionType: Constants.GAME_FETCH
      gameID: game

  answer: (card, choice) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_ANSWER
      cardID: card
      choice: choice

module.exports = PlayActions
