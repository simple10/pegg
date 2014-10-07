AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

PlayActions =
  load: (flow, script) ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_APP
      flow: flow
      script: script

  pref: (card, choice, plug, thumb) ->
    AppDispatcher.handleViewAction
      actionType: Constants.PREF_SUBMIT
      card: card
      choice: choice
      plug: plug
      thumb: thumb

  pegg: (peggeeId, card, choice, answer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.PEGG_SUBMIT
      peggeeId: peggeeId
      card: card
      choice: choice
      answer: answer

  plug: (card, full, thumb) ->
    AppDispatcher.handleViewAction
      actionType: Constants.PLUG_IMAGE
      card: card
      full: full
      thumb: thumb

  rate: (rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_RATE
      rating: rating

  pass: (card) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_PASS
      card: card

  mood: (moodText, moodId, moodUrl) ->
    AppDispatcher.handleViewAction
      actionType: Constants.PICK_MOOD
      moodText: moodText
      moodId: moodId
      moodUrl: moodUrl

  nextPage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.NEXT_PAGE

  prevPage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.PREV_PAGE

  comment: (comment, cardId, peggeeId) ->
    AppDispatcher.handleViewAction
      actionType: Constants.CARD_COMMENT
      comment: comment
      cardId: cardId
      peggeeId: peggeeId

  badgesViewed: (badges) ->
    AppDispatcher.handleViewAction
      actionType: Constants.BADGES_VIEWED
      badges: badges

module.exports = PlayActions
