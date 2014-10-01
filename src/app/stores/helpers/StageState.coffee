EventHandler = require 'famous/core/EventHandler'
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

  _fetchPrefs: (num, mood) ->
    # Gets unanswered preferences: cards the user answers about himself
    cardsLoaded = false
    user = UserStore.getUser()
    DB.getUnpreffedCards( num, mood, user.id
      (cards) =>
        @_cardSet = cards
        for own id, card of cards
          cardsLoaded = true
          card.firstName = user.get 'first_name'
          card.pic = user.get 'avatar_url'
          # FIXME periodically this will return before the view is ready, causing an error. Should be made syncronous.
          @_fetchChoices id
        if cardsLoaded
          @_playerId =  UserStore.getUser().id
          @emit Constants.stores.CARDS_CHANGE
        else
          @_fetchPrefsDone()
    )

  _fetchPeggs: (num) ->
    # Gets unpegged preferences: cards the user answers about a friend
    cardsLoaded = false
    DB.getPeggCards( num, UserStore.getUser()
      (cards) =>
        @_cardSet = cards
        for own id, card of cards
          cardsLoaded = true
          @_playerId = card.peggee
          @_fetchChoices id
        if cardsLoaded
          @emit Constants.stores.CARDS_CHANGE
        else
          @_fetchPeggsDone()
    )

  _fetchChoices: (cardId) ->
    DB.getChoices(cardId
      (choices) =>
        for choice in choices
          text = choice.get 'text'
          plug = choice.get 'plug'
          thumb = choice.get 'plugThumb'
          # only add choices that are not blank
          if text isnt ''
            # image isnt '' and
            @_cardSet[cardId].choices.push
              id: choice.id
              text: text
              plug: plug
              thumb: thumb
        @emit Constants.stores.CHOICES_CHANGE,
          cardId: cardId
          choices: @_cardSet[cardId].choices
    )

  _fetchRanking: (userId) ->
    DB.getTopScores(userId,
      (points) =>
        @_status['stats'] = points
        @emit Constants.stores.STATUS_CHANGE
      )

  _fetchNewBadges: (userId) ->
    DB.getNewBadges(userId,
      (badges) =>
        if badges?
          @_badges = badges
          @emit Constants.stores.BADGE_CHANGE
        else
          @loadStatus()
      )

  _fetchLikeness: (cards) ->
    DB.getPrefCounts(cards,
      (results) =>
        # mash up results with cards played
        for own id, card of cards
          for choice in card.choices
            if results[id]?
              unless choice.id of results[id].choices
                results[id].choices[choice.id] = {
                  choiceText: choice.text
                  count: 0
                }
        @_status['stats'] = results
        @emit Constants.stores.STATUS_CHANGE
      )

  _fetchMoods: ->
    DB.getTodaysMoods( (results) =>
      @_status['moods'] = results
      @emit Constants.stores.STATUS_CHANGE
    )

  _fetchPrefsDone: ->
    @_status['type'] = 'prefs_done'
    @emit Constants.stores.STATUS_CHANGE

  _fetchPeggsDone: ->
    @_status['type'] = 'peggs_done'
    @emit Constants.stores.STATUS_CHANGE


module.exports = StageState
