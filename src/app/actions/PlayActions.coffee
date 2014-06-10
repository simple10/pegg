AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants')

PlayActions =
  load: (game) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.GAME_FETCH
      gameID: game

  answer: (choice) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_ANSWER
      choice: choice

  rate: (rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_RATE
      rating: rating

  pick: (card) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_PICK
      cardID: card

module.exports = PlayActions
