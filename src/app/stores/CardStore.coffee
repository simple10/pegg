EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'


class CardStore extends EventEmitter
  constructor: ->
    @_cards = []

  getCards: ->
    @_cards

  add: (card) ->
    @_cards.push card

class Card
  constructor: (options) ->
    @_author = options.author # ? raise xxx

  addQuestion: (question) ->
    @_question = question


cardStore = new CardStore

module.exports = {cardStore, Card}



