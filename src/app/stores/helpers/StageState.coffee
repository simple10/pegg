EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


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
    DB.getPrefCards(
      num
      UserStore.getUser()
      (cardId) =>
        @_fetchChoices cardId
      (cards) =>
        if cards?
          @_cardSet = cards
          for own id, card of cards
            @_fetchChoices id
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchPeggCards: (num) ->
    # Gets unpegged preferences: cards the user answers about a friend
    @_cardSet = {}
    DB.getPeggCards(
      num
      UserStore.getUser()
      (cards) =>
        if cards?
          @_cardSet = cards
          for own id, card of cards
            @_fetchChoices id
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchChoices: (cardId) ->
    DB.getChoices(
      @_cardSet
      cardId
      (cards) =>
        @_cardSet = cards
        @emit Constants.stores.CHOICES_CHANGE, cardId
    )

module.exports = StageState
