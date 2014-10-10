DB = require 'stores/helpers/ParseBackend'
Parse = require 'Parse'
_ = Parse._

# Famo.us
EventHandler = require 'famous/src/core/EventHandler'

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
MessageActions = require 'actions/MessageActions'

class PlayStore extends EventHandler
  _currentPage: -1
  _fails: 0
  _game: null
  _size: 4
  _mood: {}
  _peggee: {}
  # _cardSet = {}
  # _playerId = ""
  # _play = data[0]   # the cards to play
  # _status = data[1]   # the status screen to display
  _badge = {}

  _loadMoodGame: ->
    MessageActions.loading 'game'
    @_fetchPeggs()
      .fail @_failHandler
      .done (cards...) =>
        @_loadGame cards

  _loadPeggeeGame: ->
    MessageActions.loading 'game'
    @_fetchPeggs()
      .fail @_failHandler
      .done (cards...) =>
        @_loadGame cards

  _loadUser: ->
    @_user = UserStore.getUser()
    @_avatar = UserStore.getAvatar()

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
        if peggCard.hasPreffed.indexOf @_user.id is -1
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
      @_fetchPrefs()
        .then (cards...) =>
          prefCards = {}
          for card in cards
            prefCards[card.id] = card
          DB.getPrefPopularities (prefCards)
            .then (prefPops) =>
              @_sortGame(prefCards, prefPops)

  _sortGame: (prefCards, prefPopularities, peggCards, topPeggers) =>
    if arguments.length is 2
      for own cardId, prefCard of prefCards
        @_game.push {type: 'card', card: prefCard}                                # pref card
        @_game.push {type: 'prefPopularities', stats: prefPopularities[cardId]}   # pref popularity
    else
      for own cardId, peggCard of peggCards
        peggeeId = peggCard.peggeeId
        @_game.push {type: 'card', card: peggCard}                                # pegg card
        @_game.push {type: 'topPeggers', stats: topPeggers[peggeeId]}             # top peggers
        if prefCards[cardId]?
          @_game.push {type: 'card', card: prefCards[cardId]}                     # pref card
          @_game.push {type: 'prefPopularities', stats: prefPopularities[cardId]} # pref popularity

    @_game.push {type: 'done'} # done screen


  _peggToPref: (card) ->
    card = _.clone card
    delete card.answer
    card.peggeeId = @_user.id
    card.firstName = @_user.get 'first_name'
    card.pic = @_avatar
    card

  _fetchPrefs: =>
    # Gets unanswered preferences: cards the user answers about himself
    DB.getUnpreffedCards @_size, @_mood, @_user
      .then @_loadAncillaryDatums

  _fetchPeggs: =>
    # Gets unpegged preferences: cards the user answers about a friend
    DB.getPeggCards @_size, @_user, @_mood.id, @_peggee.id
      .then @_loadAncillaryDatums

  _loadAncillaryDatums: (cards) =>
    dataDone = []
    for own cardId, card of cards
      dataDone.push @_fetchChoices(card).then @_fetchComments
    Parse.Promise.when dataDone

  _fetchComments: (card) ->
    if card.peggeeId?
      DB.getComments card.id, card.peggeeId
        .then (comments) =>
          card.comments = comments
          card
    else
      Parse.Promise.as card

  _fetchChoices: (card) ->
    DB.getChoices card.id
      .then (choices) =>
        card.choices = choices
        card

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
    @_fetchNewBadge @_user.id
      .then (isBadge) =>
        if !isBadge
          @_currentPage++
          @_fails = 0
          page = @getCurrentPage()
          if page.type is 'card'
            if page.card.peggeeId? and page.card.peggeeId isnt @_user.id
              @_title = "Pegg #{page.card.firstName}!"
              MessageActions.show 'tutorial__first_pegg_card'
            else
              @_title = "Pegg yourself!"
              MessageActions.show 'tutorial__first_unpreffed_card'
          @emit Constants.stores.PAGE_CHANGE

  _prev: ->
    @_currentPage--


  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId

    # Save pegg
    DB.savePegg peggeeId, cardId, choiceId, answerId, @_user.id
      .fail @_failHandler
      .done =>
        if choiceId is answerId
          points = 10 - 3 * @_fails
          @emit Constants.stores.CARD_WIN, points
          DB.savePoints @_user.id, peggeeId, points
            .fail @_failHandler
          @_savePeggActivity cardId, peggeeId, @_fails + 1
        else
          @_fails++
          @emit Constants.stores.CARD_FAIL


  _pref: (cardId, choiceId, plug, thumb) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId

    # save answered status
    @getCurrentPage().answered = true

#    sPlug = JSON.stringify plug
#    sThumb = JSON.stringify thumb

    DB.savePref cardId, choiceId, plug, thumb, @_user.id, @_mood.id
      .fail @_failHandler
      .done =>
        DB.savePrefCount cardId, choiceId
          .fail @_failHandler
        @_savePrefActivity cardId
        @emit Constants.stores.PREF_SAVED

  _saveMoodActivity: (moodId, moodText, moodUrl) ->
    message = "#{@_user.get 'first_name'} is feeling #{moodText}"
    DB.saveActivity message, moodUrl, @_user.id
      .fail @_failHandler

  _saveNewCardActivity: (cardId, question, pic) ->
    message = "#{@_user.get 'first_name'} created card: #{question}"
    DB.saveActivity message, pic, @_user.id, cardId
      .fail @_failHandler

  _savePrefActivity: (cardId) ->
    DB.getPrefCard cardId, @_user.id
      .fail @_failHandler
      .done (prefCard) =>
        himHerSelf = if prefCard.gender is 'male' then 'himself' else 'herself'
        message = "#{prefCard.firstName} pegged #{himHerSelf}: #{prefCard.question}"
        DB.saveActivity message, prefCard.pic, @_user.id, cardId, @_user.id
          .fail @_failHandler

  _savePeggActivity: (cardId, peggeeId, tries) ->
    DB.getPrefCard cardId, peggeeId
      .fail @_failHandler
      .done (prefCard) =>
        trys = if tries is 1 then 'try' else 'tries'
        message = "#{@_user.get 'first_name'} pegged #{prefCard.firstName} in #{tries} #{trys}: #{prefCard.question}"
        DB.saveActivity message, @_avatar, @_user.id, cardId, peggeeId
          .fail @_failHandler

  _saveCommentActivity: (comment, peggeeId, cardId) ->
    message = "#{@_user.get 'first_name'} commented: #{comment}"
    DB.saveActivity message, @_avatar, @_user.id, cardId, peggeeId
      .fail @_failHandler

  _plug: (cardId, full, thumb) ->
    console.log "save Plug: card: " + cardId + " image: " + full
    @_user.id = UserStore.getUser().id

    DB.savePlug cardId, full, thumb, @_user.id
      .fail @_failHandler
      .done =>
        @emit Constants.stores.PLUG_SAVED

  _failHandler: (error) ->
    console.log "ERROR:", error

  _comment: (comment, cardId, peggeeId) ->
    console.log "comment: #{comment}  peggee: #{peggeeId}  card: #{cardId}"
    DB.saveComment comment, cardId, peggeeId, @_user.id, @_avatar
      .fail @_failHandler
      .done (res) =>
        @getCurrentPage().card.comments.unshift res
        @_saveCommentActivity comment, peggeeId, cardId

  _setMood: (moodText, moodId, moodUrl) ->
    console.log "moodId: " + moodId
    @_mood = { text: moodText, id: moodId, url: moodUrl }
    @_loadMoodGame moodId
    DB.saveMood moodId, @_user.id
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

  getComments: ->
    page = @getCurrentPage()
    if page.type is 'card'
      return page.card.comments
    else
      return null

  getMoods: ->
    @_moods

  getBadge: ->
    @_badge

  getGameState: ->
    mood: @_mood
    title: @_title
    position: @_currentPage
    size: @_game.length

  getMessage: (status) ->
    switch status
      when 'win' then return "Good job!"
      when 'fail' then return "Boo."

play = new PlayStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.LOAD_APP
      play._loadUser()
      play._fetchMoods()
    when Constants.actions.PEGG_SUBMIT
      play._pegg action.peggeeId, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      play._pref action.card, action.choice, action.plug, action.thumb
    when Constants.actions.PLUG_IMAGE
      play._plug action.card, action.full, action.thumb
    when Constants.actions.NEXT_PAGE
      play._next()
    when Constants.actions.PREV_PAGE
      play._prev()
    when Constants.actions.CARD_COMMENT
      play._comment action.comment, action.cardId, action.peggeeId
    when Constants.actions.PICK_MOOD
      play._setMood action.moodText, action.moodId, action.moodUrl
    when Constants.actions.BADGES_VIEWED
      play._badgesViewed(action.badges)

module.exports = play
