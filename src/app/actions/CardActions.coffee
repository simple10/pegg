AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants')

CardActions =

  addQuestion: (question) ->
   AppDispatcher.handleViewAction
     actionType: Constants.actions.ADD_QUESTION
     question: question

  addAnswers: (answers) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.ADD_ANSWERS
      answers: answers

  loadCategories: () ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.LOAD_CATEGORIES

  addCategories: (categories) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.ADD_CATEGORIES
      categories: categories

module.exports = CardActions
