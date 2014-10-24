AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

SingleCardActions =
  load: (cardId, peggeeId, referrer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_LOAD
      card: cardId
      peggee: peggeeId
      referrer: referrer

  pref: (card, choice, plug, thumb) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PREF_SUBMIT
      card: card
      choice: choice
      plug: plug
      thumb: thumb

  pegg: (peggeeId, card, choice, answer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PEGG_SUBMIT
      peggeeId: peggeeId
      card: card
      choice: choice
      answer: answer

  plug: (card, full, thumb) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PLUG_IMAGE
      card: card
      full: full
      thumb: thumb

  comment: (comment, cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_CARD_COMMENT
      comment: comment
      cardId: cardId
      peggeeId: peggeeId

  nextPage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_NEXT_PAGE

  prevPage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.SINGLE_CARD_PREV_PAGE

module.exports = SingleCardActions
