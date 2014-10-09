EventHandler = require 'famous/src/core/EventHandler'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'


class StageState extends EventHandler

  constructor: (data) ->
    super
    @_cardSet = {}
    @_playerId = ""
    @_play = data[0]   # the cards to play
    @_status = data[1]   # the status screen to display
    @_badges = []


  loadCards: (mood) ->
    switch @_play.type
      when 'pref'
        @_fetchPrefs @_play.size, mood
      when 'pegg'
        @_fetchPeggs @_play.size
      when ''
        @_cardSet = null
      else
        console.log "Unexpected play type: #{@_play.type}"

  loadStatus: ->
    switch @_status.type
      when 'likeness_report'
        @_fetchLikeness @_cardSet
      when 'friend_ranking'
        @_fetchRanking @_playerId
      when 'pick_mood'
        @_fetchMoods()
      else
        console.log "Unexpected status type: #{@_status.type}"

  loadBadges: ->
    @_fetchNewBadges(UserStore.getUser().id)

  getChoices: (cardId) ->
    @_cardSet[cardId].choices

  getCardSet: ->
    @_cardSet

  getBadges: ->
    @_badges

  getStatus: ->
    @_status


module.exports = StageState
