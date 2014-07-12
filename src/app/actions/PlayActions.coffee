AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants')

PlayActions =
  load: (flow, script) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.SET_LOAD
      flow: flow
      script: script

  preloadComments: (card, peggee) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PRELOAD_COMMENTS
      peggee: peggee
      card: card

  pref: (card, choice) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PREF_SUBMIT
      card: card
      choice: choice

  pegg: (peggee, card, choice, answer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PEGG_SUBMIT
      peggee: peggee
      card: card
      choice: choice
      answer: answer

  rate: (rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_RATE
      rating: rating

  pass: (card) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_PASS
      card: card

  nextStage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.NEXT_STAGE

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_COMMENT
      comment: comment

module.exports = PlayActions
