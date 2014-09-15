EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class NewCardStore extends EventEmitter
  _cardId: null
  _author: null
  _question: null
  _answers: []
  _categories: []

  _addQuestion: (question) ->
    @_author = @_getUser()
    @_question = question
    DB.saveQuestion( @_author, @_question, (cardId) =>
      @_cardId = cardId
    )

  _addAnswers: (answers) ->
    @_answers = []
    @_answers.push answers...
    DB.saveChoices @_cardId, @_answers

  _addCategories: (categories) ->
    @_categories = []
    @_categories.push categories...
    DB.saveCategories @_cardId, @_categories, (message) =>
      user = UserStore.getUser()
      pic = UserStore.getAvatar()
      DB.saveNewCardActivity(@_cardId, @_question, user, pic)

  newCard: ->
    @_cardId = null
    @_author = null
    @_question = null
    @_answers = []
    @_categories = []

  _getUser: ->
    user = UserStore.getUser()
    if user.id?
      user.id
    else
      'not logged in'

  _loadCategories: ->
    DB.getCategories((results) =>
      @_categories = results
      @emit Constants.stores.CATEGORIES_CHANGE
    )

  getCard: ->
    {
      id: @_cardId
      author: @_author
      question: @_question
      answers: @_answers
      categories: @_categories
    }

  getCategories: ->
    @_categories


newCardStore = new NewCardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action
  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.ADD_QUESTION
      newCardStore._addQuestion action.question
    when Constants.actions.ADD_ANSWERS
      newCardStore._addAnswers action.answers
    when Constants.actions.LOAD_CATEGORIES
      newCardStore._loadCategories()
    when Constants.actions.ADD_CATEGORIES
      newCardStore._addCategories action.categories


module.exports = newCardStore


