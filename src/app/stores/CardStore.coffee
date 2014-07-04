EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'


class CardStore extends EventEmitter
  constructor: ->
    @_cards = []

  getCards: ->
    @_cards

  add: (card) ->
    newCard = new Card card
    @_cards.push newCard
    newCard

class Card
  constructor: (options) ->
    @_author = options.author ? raise 'author required'
    @_question = options.question
    @_answers = []


  addQuestion: (question) ->
    @_question = question

  addAnswers: (answers...) ->
    @_answers.push answers...


cardStore = new CardStore

module.exports =
  CardStore: cardStore
  Card: Card

