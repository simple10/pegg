EventHandler = require 'famous/core/EventHandler'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class StageState extends EventHandler
  _cardSet = {}
  _status = null
  _play = null
  _playerId = ""

  constructor: (data) ->
    super
    @_play = data[0]   # the cards to play
    @_status = data[1]   # the status screen to display


  loadCards: ->
    switch @_play.type
      when 'pref'
        @_fetchPrefs @_play.size
      when 'pegg'
        @_fetchPeggs @_play.size
      else
        raise "unexpected play type: #{@_play.type}"

  loadStatus: ->
    switch @_status.type
      when 'likeness_report'
        @_fetchLikeness @_cardSet
      when 'friend_ranking'
        @_fetchRanking @_playerId
      else
        raise "unexpected status type: #{@_status.type}"


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
            @_fetchPrefChoices id
          @_playerId =  UserStore.getUser().id
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
            friend = card.peggee
            @_fetchPeggChoices id, friend
          @_playerId = friend
          @emit Constants.stores.CARDS_CHANGE
    )

  _fetchPrefChoices: (cardId) ->
    DB.getPrefChoices( @_cardSet, cardId
      (cards) =>
        @_cardSet = cards
        @emit Constants.stores.CHOICES_CHANGE, cardId
    )

  _fetchPeggChoices: (cardId, friendId) ->
    DB.getPeggChoices( @_cardSet, cardId, friendId
      (cards) =>
        @_cardSet = cards
        @emit Constants.stores.CHOICES_CHANGE, cardId
    )

  _fetchRanking: (userId) ->
    DB.getTopScores(userId,
      (points) =>
        @_status['stats'] = points
        @emit Constants.stores.STATUS_CHANGE
      )

  _fetchLikeness: (cards) ->
    DB.getPrefCounts(cards,
      (results) =>
        # mash up results with cards played
        for own id, card of cards
          for choice in card.choices
            unless choice.id of results[id].choices
              results[id].choices[choice.id] = {
                choiceText: choice.text
                count: 0
              }
        # TODO: handle edge case: no results
        @_status['stats'] = results
        @emit Constants.stores.STATUS_CHANGE
      )


module.exports = StageState
