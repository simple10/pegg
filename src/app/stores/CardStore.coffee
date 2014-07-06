EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'


class CardStore extends EventEmitter
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
    @_saveCard()

  addAnswers: (answers) ->
    @_answers = []
    @_answers.push answers...
    @_saveCard()

  addCategories: (categories) ->
    @_categories = []
    @_categories.push categories...
    @_saveCard()

  _saveCard: ->
    console.log @getCard()
    # TODO: save to Parse

  _getUser: ->
    user = UserStore.getUser() ? raise 'not logged in'
    user.id


cardStore = new CardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action
  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.ADD_QUESTION
      cardStore.addQuestion action.question
    when Constants.actions.ADD_ANSWERS
      cardStore.addAnswers action.answers

module.exports = cardStore


