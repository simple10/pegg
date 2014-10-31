AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions

PlayActions =
  load: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.LOAD_MOOD

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
