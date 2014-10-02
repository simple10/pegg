DB = require 'stores/helpers/ParseBackend'

# Famo.us
EventHandler = require 'famous/core/EventHandler'

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require 'constants/PeggConstants'
GameState = require 'stores/helpers/GameState'
UserStore = require 'stores/UserStore'

class PlayStore extends EventHandler
  _currentPage: null
  _fails: 0
  _game: null
  _showHelpMessages: true
  # _cardSet = {}
  # _playerId = ""
  # _play = data[0]   # the cards to play
  # _status = data[1]   # the status screen to display
  # _badges = []

  _loadMoodGame: (type, size, moodId) ->
    @_fetchPeggs size, moodId, null
      .fail @_failHandler
      .done (cards) =>
        @_loadGame cards

  _loadPeggeeGame: (type, size, peggeeId) ->
    @_fetchPeggs size, null, peggeeId
      .fail @_failHandler
      .done (cards) =>
        @_loadGame cards

  _loadGame: (cards) ->
    @_user = UserStore.getUser()
    @_avatar = UserStore.getAvatar 'type=square'
    @_game = []
    # @_fetchPrefs

    # for each card in cards
    #   put help message in game
    #   put card in game
    #   put pegg status in game
    #   if card not preffed
    #     fetch pref card
    #     put help message in game
    #     put pref card in game
    #     put pref status in game
    # put done status in game

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

  _fetchPeggs: (num, moodId, peggeeId) ->
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

  _next: ->
    @_currentPage++
    page = @getCurrentPage()
    if page.type is 'help' and not @_showHelpMessages
      @_currentPage++

  _prev: ->
    @_currentPage--
    page = @getCurrentPage()
    if page.type is 'help' and not @_showHelpMessages
      @_currentPage--

  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId

    # Save pegg
    DB.savePegg peggeeId, cardId, choiceId, answerId, @_user.id
      .fail @_failHandler
      .done =>
        if choiceId is answerId
          points = 10 - 3 * @_fails
          @_fails = 0
          @emit Constants.stores.CARD_WIN, points
          DB.savePoints @_user.id, peggeeId, points
            .fail @_failHandler
          @_savePeggActivity cardId, @_user, peggeeId, @_fails
        else
          @_fails++
          @emit Constants.stores.CARD_FAIL

  _pref: (cardId, choiceId, plug, thumb) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId

    # save answered status
    @getCurrentPage().answered = true

    sPlug = JSON.stringify plug
    sThumb = JSON.stringify thumb

    DB.savePref cardId, choiceId, sPlug, sThumb, @_user.id
      .fail @_failHandler
      .done =>
        DB.savePrefCount cardId, choiceId
          .fail @_failHandler
        @_savePrefActivity cardId, @_user.id
        @emit Constants.stores.PREF_SAVED

  _saveMoodActivity: (moodId) ->
    DB.getUserMood moodId, @_user.id
      .fail @_failHandler
      .done (mood) =>
        message = "#{mood.firstName} is feeling #{mood.name}"
        DB.saveActivity message, mood.pic, @_user.id
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
        message = "#{@_user.firstName} pegged #{prefCard.firstName} in #{tries} #{trys}: #{prefCard.question}"
        DB.saveActivity message, @_avatar, @_user.id, cardId, peggeeId
          .fail @_failHandler

  _saveCommentActivity: (comment, peggeeId, cardId) ->
    message = "#{@_user.get 'first_name'} commented: #{comment}"
    DB.saveActivity message, @_avatar, @_user.id, cardId, peggeeId
      .fail @_failHandler

  getCurrentPage: ->
    @_game[@_currentPage]

  _plug: (cardId, full, thumb) ->
    console.log "save Plug: card: " + cardId + " image: " + full
    @_user.id = UserStore.getUser().id

    DB.savePlug cardId, full, thumb, @_user.id
      .fail @_failHandler
      .done =>
        @emit Constants.stores.PLUG_SAVED

  _failHandler: (error) ->
    alert error

  _comment: (comment, cardId, peggeeId) ->
    console.log "comment: #{comment}  peggee: #{peggeeId}  card: #{cardId}"
    DB.saveComment comment, cardId, peggeeId, @_user.id, @_avatar
      .fail @_failHandler
      .done (res) =>
        @getCurrentPage().comments.unshift res
        @_saveCommentActivity comment, peggeeId, cardId
        @emit Constants.stores.COMMENTS_CHANGE

  _mood: (moodText, moodId, moodUrl) ->
    console.log "moodId: " + moodId
    _loadGame moodText, moodId, moodUrl
    DB.saveMood moodId, @_user.id
      .fail @_failHandler
      .done =>
        @emit Constants.stores.MOOD_CHANGE
        @_saveMoodActivity(moodId, moodText, moodUrl, @_user.id)

  _badgesViewed: (badges) ->
    # mark the current badges as viewed
    DB.saveBadgeView badges, @_user.id
      .fail @_failHandler
      .done =>
        @_next()

  getComments: ->
    @getCurrentPage().comments

  getChoices: ->
    @getCurrentPage().choices

play = new PlayStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    # when Constants.actions.LOAD_GAME
    #   play._loadGame action.type, action.size
    when Constants.actions.PEGG_SUBMIT
      play._pegg action.peggee, action.card, action.choice, action.answer
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
      play._mood action.moodText, action.moodId, action.moodUrl
    when Constants.actions.BADGES_VIEWED
      play._badgesViewed(action.badges)

module.exports = play
