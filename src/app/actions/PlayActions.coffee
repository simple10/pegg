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

  rate: (card, rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.RATE_CARD
      cardID: card
      rating: rating

module.exports = PlayActions
