AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants')

PlayActions =
  load: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.SET_LOAD

  pref: (card, choice) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PREF_SUBMIT
      card: card
      choice: choice

  pegg: (peggee, card, choice) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PEGG_SUBMIT
      peggee: peggee
      card: card
      choice: choice

  rate: (rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_RATE
      rating: rating

  pass: (card) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_PASS
      card: card

  continue: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PLAY_CONTINUE

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_COMMENT
      comment: comment

module.exports = PlayActions
