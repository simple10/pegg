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
        @_fetchPrefs @_play.size
      when 'pegg'
        @_fetchPeggs @_play.size
      else
        raise "unexpected play type: #{@_play.type}"

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getCardSet: ->
    @_cardSet

  getStatus: ->
    @_status

  _fetchPrefs: (num) ->
    # Gets unanswered preferences: cards the user answers about himself
    @_cardSet  = {}
    DB.getPrefCards( num, UserStore.getUser()
      (cards) =>
        if cards?
          @_cardSet = cards
          for own id, card of cards
            @_fetchChoices id
          @_fetchStatus UserStore.getUser().id
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchPeggs: (num) ->
    # Gets unpegged preferences: cards the user answers about a friend
    @_cardSet = {}
    DB.getPeggCards( num, UserStore.getUser()
      (cards) =>
        if cards?
          @_cardSet = cards
          friend = ""
          for own id, card of cards
            friend = id
            @_fetchChoices id
          @_fetchStatus friend
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchChoices: (cardId) ->
    DB.getChoices( @_cardSet, cardId
      (cards) =>
        @_cardSet = cards
        @emit Constants.stores.CHOICES_CHANGE, cardId
    )

  _fetchStatus: (userId) ->
    switch @_status.type
      when 'profile_progress'
        DB.getTopPoints(userId,
          (points) =>
            @_status['points'] = points
          )
      when 'friend_ranking'
        DB.getTopPoints(userId,
          (points) =>
            @_status['points'] = points
          )
      else
        raise "unexpected status type: #{@_status.type}"

module.exports = StageState
