AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants')

PlayActions =
  load: (flow, script) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.LOAD_GAME
      flow: flow
      script: script

  pref: (card, choice, plug) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PREF_SUBMIT
      card: card
      choice: choice
      plug: plug

  pegg: (peggee, card, choice, answer) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PEGG_SUBMIT
      peggee: peggee
      card: card
      choice: choice
      answer: answer

  plug: (card, url) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PLUG_IMAGE
      card: card
      url: url

  rate: (rating) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_RATE
      rating: rating

  pass: (card) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_PASS
      card: card

  mood: (moodText, moodId, moodUrl) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PICK_MOOD
      moodText: moodText
      moodId: moodId
      moodUrl: moodUrl

  nextStage: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.NEXT_STAGE

  nextCard: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.NEXT_CARD

  prevCard: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.PREV_CARD

  comment: (comment) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.CARD_COMMENT
      comment: comment

  badgesViewed: (badges) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.BADGES_VIEWED
      badges: badges

module.exports = PlayActions
