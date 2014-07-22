EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class StageState extends EventHandler
  _cardSet = {}
  _status = null

  constructor: (data) ->
    super
    @_play = data[0]   # the cards to play
    @_status = data[1]   # the status screen to display


  load: ->
    switch @_play.type
      when 'pref'
        @_fetchPrefCards @_play.size
      when 'pegg'
        @_fetchPeggCards @_play.size
      else
        raise "unexpected play type: #{@_play.type}"

    switch @_status.type
      when 'profile_progress'
        # TODO: load profile progress
        console.log 'profile_progress'
      when 'friend_ranking'
        # TODO: load friend stats
        console.log 'friend_ranking'
      else
        raise "unexpected status type: #{@_status.type}"

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getCardSet: ->
    @_cardSet

  getStatus: ->
    @_status

  _fetchPrefCards: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @_cardSet  = {}
    DB.getPrefCards( num, UserStore.getUser()
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
    DB.getPeggCards( num, UserStore.getUser()
      (cards) =>
        if cards?
          @_cardSet = cards
          for own id, card of cards
            @_fetchChoices id
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchChoices: (cardId) ->
    DB.getChoices( @_cardSet, cardId
      (cards) =>
        @_cardSet = cards
        @emit Constants.stores.CHOICES_CHANGE, cardId
    )

module.exports = StageState
