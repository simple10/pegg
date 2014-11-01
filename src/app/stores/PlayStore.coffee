DB = require 'stores/helpers/ParseBackend'
Parse = require 'Parse'
_ = Parse._

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
CardStore = require 'stores/CardStore'
Constants = require 'constants/PeggConstants'
MessageActions = require 'actions/MessageActions'
UserStore = require 'stores/UserStore'

class PlayStore extends CardStore
  _currentPage: -1
  _game: null
  _size: 4
  _mood: {}
  _peggee: {}
  _badge: {}

  _loadMoodGame: ->
    MessageActions.loading 'game'
    @_fetchPeggCards()
      .fail @_failHandler
      .done (cards...) =>
        @_loadGame cards

  _loadPeggeeGame: ->
    MessageActions.loading 'game'
    @_fetchPeggCards()
      .fail @_failHandler
      .done (cards...) =>
        @_loadGame cards

  _loadGame: (cards) ->
    @_game = []
    @_currentPage = -1
    dataLoaded = []

    console.log "peggCards: ", cards

    if cards? and cards.length > 0
      peggCards = {}
      for card in cards
        peggCards[card.id] = card

      prefCards = {}
      peggeeIds = []
      for own cardId, peggCard of peggCards
        peggeeIds.push peggCard.peggeeId
        if peggCard.hasPreffed.indexOf(UserStore.getUser().id) is -1
          prefCards[cardId] = @_peggToPref peggCard

      dataLoaded.push Parse.Promise.as prefCards
      dataLoaded.push DB.getPrefPopularities prefCards
      dataLoaded.push Parse.Promise.as peggCards
      dataLoaded.push DB.getTopPeggers peggeeIds

      Parse.Promise.when dataLoaded
        .then @_sortGame
        .done =>
          MessageActions.doneLoading 'game'
          @emit Constants.stores.GAME_LOADED
          @_next()

    else
      # if no pegg cards, fetch unpreffed cards for mood & pref popularities
      @_fetchUnpreffedCards()
        .then (cards...) =>
          prefCards = {}
          for card in cards
            prefCards[card.id] = card
          DB.getPrefPopularities (prefCards)
            .then (prefPops) =>
              @_sortGame(prefCards, prefPops)
            .done =>
              MessageActions.doneLoading 'game'
              @emit Constants.stores.GAME_LOADED
              @_next()

  _sortGame: (prefCards, prefPopularities, peggCards, topPeggers) =>
    if arguments.length is 2
      for own cardId, prefCard of prefCards
        @_game.push {type: 'card', card: prefCard}                                # pref card
        if prefPopularities[cardId]?
          @_game.push {type: 'prefPopularities', stats: prefPopularities[cardId]} # pref popularity
    else
      for own cardId, peggCard of peggCards
        peggeeId = peggCard.peggeeId
        @_game.push {type: 'card', card: peggCard}                                # pegg card
        if topPeggers[peggeeId]?
          @_game.push {type: 'topPeggers', stats: topPeggers[peggeeId]}           # top peggers
        if prefCards[cardId]?
          @_game.push {type: 'card', card: prefCards[cardId]}                     # pref card
        if prefPopularities[cardId]?
          @_game.push {type: 'prefPopularities', stats: prefPopularities[cardId]} # pref popularity

    @_game.push {type: 'done'} # done screen


  _peggToPref: (card) ->
    card = _.clone card
    delete card.answer
    card.peggeeId = UserStore.getUser().id
    card.firstName = UserStore.getUser().get 'first_name'
    card.pic = UserStore.getAvatar()
    card

  _fetchUnpreffedCards: =>
    # Gets unanswered preferences: cards the user answers about himself
    DB.getUnpreffedCards @_size, @_mood, UserStore.getUser()
      .then @_loadAncillaryDatums

  _fetchPeggCards: =>
    # Gets unpegged preferences: cards the user answers about a friend
    DB.getPeggCards @_size, UserStore.getUser(), @_mood.id, @_peggee.id
      .then @_loadAncillaryDatums

  _fetchNewBadge: (userId) ->
    DB.getNewBadge userId
      .then (badge) =>
        if badge?
          @_badge = badge
          @emit Constants.stores.BADGE_CHANGE
          true
        else
          false

  _next: ->
    @_fetchNewBadge UserStore.getUser().id
      .then (isBadge) =>
        if !isBadge
          @_currentPage++
          @_fails = 0
          page = @getCurrentPage()
          if page.type is 'card'
            if page.card.peggeeId? and page.card.peggeeId isnt UserStore.getUser().id
              @_title = "Pegg #{page.card.firstName}!"
              MessageActions.show 'tutorial__first_pegg_card'
            else
              @_title = "Pegg yourself!"
              MessageActions.show 'tutorial__first_unpreffed_card'
          @emit Constants.stores.PAGE_CHANGE

  _prev: ->
    @_currentPage--

  _pref: (cardId, choiceId, plug, thumb) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId

    # save answered status
    @getCurrentPage().answered = true

#    sPlug = JSON.stringify plug
#    sThumb = JSON.stringify thumb

    DB.savePref cardId, choiceId, plug, thumb, UserStore.getUser().id, @_mood.id
      .fail @_failHandler
      .done =>
        DB.savePrefCount cardId, choiceId
          .fail @_failHandler
        @_savePrefActivity cardId
        @emit Constants.stores.PREF_SAVED

  _saveMoodActivity: (moodId, moodText, moodUrl) ->
    message = "#{UserStore.getUser().get 'first_name'} is feeling #{moodText}"
    DB.saveActivity message, moodUrl, UserStore.getUser().id
      .fail @_failHandler

  _saveNewCardActivity: (cardId, question, pic) ->
    message = "#{UserStore.getUser().get 'first_name'} created card: #{question}"
    DB.saveActivity message, pic, UserStore.getUser().id, cardId
      .fail @_failHandler

  _setMood: (moodText, moodId, moodUrl) ->
    console.log "moodId: " + moodId
    @_mood = { text: moodText, id: moodId, url: moodUrl }
    @_loadMoodGame moodId
    DB.saveMood moodId, UserStore.getUser().id
      .fail @_failHandler
      .done =>
        # TODO change playnav to do this on game change:
        # @emit Constants.stores.MOOD_CHANGE
        @_saveMoodActivity(moodId, moodText, moodUrl)

  _badgesViewed: (badge) ->
    # mark the current badge as viewed
    DB.saveBadgeView badge.userBadgeId
      .fail @_failHandler
      .done =>
        @_next()

  _fetchMoods: =>
    DB.getTodaysMoods()
      .then (results) =>
        @_moods = results
        @emit Constants.stores.MOODS_LOADED

  getCurrentPage: ->
    @_game[@_currentPage]

  getMoods: ->
    @_moods

  getBadge: ->
    @_badge

  getGameState: ->
    mood: @_mood
    title: @_title
    position: @_currentPage
    size: @_game.length

play = new PlayStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.LOAD_MOOD
      play._fetchMoods()
    when Constants.actions.NEXT_PAGE
      play._next()
    when Constants.actions.PREV_PAGE
      play._prev()
    when Constants.actions.PICK_MOOD
      play._setMood action.moodText, action.moodId, action.moodUrl
    when Constants.actions.BADGES_VIEWED
      play._badgesViewed(action.badges)
    when Constants.actions.PEGG_SUBMIT
      play._pegg action.peggeeId, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      play._pref action.card, action.choice, action.plug, action.thumb
    when Constants.actions.PLUG_IMAGE
      play._plug action.card, action.full, action.thumb
    when Constants.actions.CARD_COMMENT
      play._comment action.comment, action.cardId, action.peggeeId


module.exports = play
