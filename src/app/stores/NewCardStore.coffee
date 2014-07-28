EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class NewCardStore extends EventEmitter
  _author: null
  _question: null
  _answers: []
  _categories: []

  getCard: ->
    {
      author: @_author
      question: @_question
      answers: @_answers
      categories: @_categories
    }

  addQuestion: (question) ->
    @_author = @_getUser()
    @_question = question
    DB.saveQuestion( @_author, @_question, (cardId) =>
      @_cardId = cardId
    )

  addAnswers: (answers) ->
    @_answers = []
    @_answers.push answers...
    DB.saveChoices @_cardId, @_answers

  addCategories: (categories) ->
    @_categories = []
    @_categories.push categories...
    DB.saveCategories @_cardId, @_categories

  _getUser: ->
    user = UserStore.getUser() ? raise 'not logged in'
    user.id


newCardStore = new NewCardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action
  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.ADD_QUESTION
      newCardStore.addQuestion action.question
    when Constants.actions.ADD_ANSWERS
      newCardStore.addAnswers action.answers

module.exports = newCardStore


