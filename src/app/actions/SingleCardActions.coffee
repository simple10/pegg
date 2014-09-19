AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

SingleCardActions =
  load: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_LOAD
      card: cardId
      peggee: peggeeId
      referrer: referrer

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_COMMENT
      comment: comment

  plug: (card, full, thumb) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PLUG
      card: card
      full: full
      thumb: thumb

  pref: (card, choice, plug) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PREF
      card: card
      choice: choice
      plug: plug

  pegg: (peggee, card, choice, answer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PEGG
      peggee: peggee
      card: card
      choice: choice
      answer: answer

module.exports = SingleCardActions
