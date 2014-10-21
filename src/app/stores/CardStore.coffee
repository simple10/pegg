DB = require 'stores/helpers/ParseBackend'
Parse = require 'Parse'

# Famo.us
EventHandler = require 'famous/src/core/EventHandler'

# Pegg
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'

class CardStore extends EventHandler
  _fails: 0

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

  _savePrefActivity: (cardId) ->
    DB.getPrefCard cardId, UserStore.getUser().id
      .fail @_failHandler
      .done (prefCard) =>
        himHerSelf = if prefCard.gender is 'male' then 'himself' else 'herself'
        message = "#{prefCard.firstName} pegged #{himHerSelf}: #{prefCard.question}"
        DB.saveActivity message, prefCard.pic, UserStore.getUser().id, cardId, UserStore.getUser().id
          .fail @_failHandler

  _savePeggActivity: (cardId, peggeeId, tries) ->
    DB.getPrefCard cardId, peggeeId
      .fail @_failHandler
      .done (prefCard) =>
        trys = if tries is 1 then 'try' else 'tries'
        message = "#{UserStore.getUser().get 'first_name'} pegged #{prefCard.firstName} in #{tries} #{trys}: #{prefCard.question}"
        DB.saveActivity message, UserStore.getAvatar(), UserStore.getUser().id, cardId, peggeeId
          .fail @_failHandler

  _saveCommentActivity: (comment, peggeeId, cardId) ->
    message = "#{UserStore.getUser().get 'first_name'} commented: #{comment}"
    DB.saveActivity message, UserStore.getAvatar(), UserStore.getUser().id, cardId, peggeeId
      .fail @_failHandler

  _plug: (cardId, full, thumb) ->
    console.log "save Plug: card: " + cardId + " image: " + full
    UserStore.getUser().id = UserStore.getUser().id

    DB.savePlug cardId, full, thumb, UserStore.getUser().id
      .fail @_failHandler
      .done =>
        @emit Constants.stores.PLUG_SAVED

  _failHandler: (error) ->
    console.error "ERROR:", error

  _comment: (comment, cardId, peggeeId) ->
    console.log "comment: #{comment}  peggee: #{peggeeId}  card: #{cardId}"
    DB.saveComment comment, cardId, peggeeId, UserStore.getUser().id, UserStore.getAvatar()
      .fail @_failHandler
      .done (res) =>
        @_saveCommentActivity comment, peggeeId, cardId

  _pegg: (peggeeId, cardId, choiceId, answerId) ->
    console.log "save Pegg: card: " + cardId + " choice: " + choiceId

    # Save pegg
    DB.savePegg peggeeId, cardId, choiceId, answerId, UserStore.getUser().id
      .fail @_failHandler
      .done =>
        if choiceId is answerId
          points = 10 - 3 * @_fails
          @emit Constants.stores.CARD_WIN, points
          DB.savePoints UserStore.getUser().id, peggeeId, points
            .fail @_failHandler
          @_savePeggActivity cardId, peggeeId, @_fails + 1
        else
          @_fails++
          @emit Constants.stores.CARD_FAIL


  _pref: (cardId, choiceId, plug, thumb) ->
    console.log "save Pref: card: " + cardId + " choice: " + choiceId

#    sPlug = JSON.stringify plug
#    sThumb = JSON.stringify thumb

    DB.savePref cardId, choiceId, plug, thumb, UserStore.getUser().id
      .fail @_failHandler
      .done =>
        DB.savePrefCount cardId, choiceId
          .fail @_failHandler
        @_savePrefActivity cardId
        @emit Constants.stores.PREF_SAVED

  getMessage: (status) ->
    switch status
      when 'win' then return "Good job!"
      when 'fail' then return "Boo."

card = new CardStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.PEGG_SUBMIT
      card._pegg action.peggeeId, action.card, action.choice, action.answer
    when Constants.actions.PREF_SUBMIT
      card._pref action.card, action.choice, action.plug, action.thumb
    when Constants.actions.PLUG_IMAGE
      card._plug action.card, action.full, action.thumb
    when Constants.actions.CARD_COMMENT
      card._comment action.comment, action.cardId, action.peggeeId

module.exports = { class: CardStore, singleton: card }
