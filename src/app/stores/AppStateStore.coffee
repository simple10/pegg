# App state handler.
#
# Manages the navigation and top level app states.
# AppStateStore listens to events broadcast by AppDispatcher,
# acts upon relevant events by fetching/storing state and
# rebroadcasts events to its listeners.
#
# For top level navigation, AppView listens to CHANGE events on
# the AppStateStore. AppStateStore triggers CHANGE events when it
# receives MENU_SELECT events from menu items via the AppDispatcher.
#
# TODO: refactor with state machine.
# See http://statejs.org

EventEmitter = require 'famous/src/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
WeActions = require 'actions/WeActions'
UserActions = require 'actions/UserActions'
SingleCardActions = require 'actions/SingleCardActions'

Parse = require 'Parse'


class AppStateStore extends EventEmitter
  _currentPageID: 'play'

  # TODO: stash currentPageID in Parse or localStorage and
  #   auto load previous app state when user returns to app.

  _loadPage: (pageID) ->
    @_currentPageID = pageID
    Parse.history.navigate pageID, trigger: false
    if pageID is 'login' or pageID is 'signup'
      @emit Constants.stores.LOGIN_CHANGE
    else if pageID is 'me'
      UserActions.load() # load user pref images
      @emit Constants.stores.MENU_CHANGE
    else if pageID is 'we'
      WeActions.loadActivity 0
      @emit Constants.stores.MENU_CHANGE
    else
      @emit Constants.stores.MENU_CHANGE

  _loadCard: (cardId, peggeeId, referrer) ->
#    console.log cardId, peggeeId
    @_currentPageID = 'card'
    Parse.history.navigate "#{@_currentPageID}/#{cardId}/#{peggeeId}", trigger: false
    peggeeUrlSegment = if peggeeId? then "/#{peggeeId}" else ""
    console.log referrer, "#{@_currentPageID}/#{cardId}#{peggeeUrlSegment}"
    SingleCardActions.load cardId, peggeeId, referrer
#    if referrer?
#      @emit Constants.stores.MENU_CHANGE

  _logout: ->
    @_currentPageID = '/'
    Parse.history.navigate @_currentPageID, trigger: false

  _login: (referrer) ->
    @_currentPageID = 'play'
#    referrer or
#    Parse.history.navigate @_currentPageID, true
    @emit Constants.stores.MENU_CHANGE
    @emit Constants.stores.LOGIN_CHANGE

  getCurrentPageID: ->
    @_currentPageID

appstate = new AppStateStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to AppStateStore
  switch action.actionType
    when Constants.actions.MENU_SELECT
      appstate._loadPage action.pageId
    when Constants.actions.CARD_SELECT
      appstate._loadCard action.cardId, action.peggeeId, action.referrer
    when Constants.actions.LOGOUT
      appstate._logout()
    when Constants.actions.LOGIN
      appstate._login action.referrer


module.exports = appstate
