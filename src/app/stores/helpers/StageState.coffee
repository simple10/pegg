EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'
Card = Parse.Object.extend 'Card'
Choice = Parse.Object.extend 'Choice'
Pref = Parse.Object.extend 'Pref'


class StageState extends EventHandler
  _cardSet = {}
  status = null

  constructor: (data) ->
    super
    @_part = data[0]   # later we will support multiple parts

  load: ->
    if @_part.type is 'pref'
      @_fetchPrefCards @_part.size
    else if @_part.type is 'pegg'
      @_fetchPeggCards @_part.size
    else
      raise "unexpected part type: #{@_part.type}"

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getCardSet: ->
    @_cardSet

  _fetchPrefCards: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @_cardSet  = {}
    user = UserStore.getUser()
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    cardQuery.notContainedIn 'hasPlayed', [user.id]
    #cardQuery.skip Math.floor(Math.random() * 180)
    cardQuery.find
      success: (cards) =>
        for card in cards
          @_cardSet[card.id] = {
            firstName: user.get 'first_name'
            pic: user.get 'avatar_url'
            question: card.get 'question'
            choices: null
          }
          @_fetchChoices(card.id)
        @emit Constants.stores.CARDS_CHANGE
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message


  _fetchPeggCards: (num) ->
    # Gets unpegged preferences: cards the user answers about a friend
    @_cardSet = {}
    user = UserStore.getUser()
    prefUser = new Parse.Object 'User'
    prefUser.set 'id', user.id
    prefQuery = new Parse.Query Pref
    prefQuery.limit num
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'choice'
    prefQuery.notEqualTo 'user', prefUser
    prefQuery.notContainedIn 'peggedBy', [user.id]
    #prefQuery.skip Math.floor(Math.random() * 300)
    prefQuery.find
      success: (prefs) =>
        for pref in prefs
          card = pref.get 'card'
          peggee = pref.get 'user'
          @_cardSet[card.id] = {
            peggee: peggee.id
            firstName: peggee.get 'first_name'
            pic: peggee.get 'avatar_url'
            question: card.get 'question'
            choices: null
            answer: pref.get 'choice'
          }
          @_fetchChoices card.id
        @emit Constants.stores.CARDS_CHANGE
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message

  _fetchChoices: (cardId) =>
    choiceQuery = new Parse.Query Choice
    choiceQuery.equalTo 'cardId', cardId
    choiceQuery.find
      success: (choices) =>
        @_cardSet[cardId].choices = []
        for choice in choices
          @_cardSet[cardId].choices.push
            id: choice.id
            text: choice.get 'text'
            image: choice.get 'image'
        @emit Constants.stores.CHOICES_CHANGE, cardId
      error: (error) ->
        console.log "Error fetching choices: " + error.code + " " + error.message


module.exports = StageState
