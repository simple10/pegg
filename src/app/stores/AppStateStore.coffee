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

EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'

Parse = require 'Parse'


class AppStateStore extends EventEmitter
  _currentPageID: 'play'

  _loadPage: (pageID) ->
    @_currentPageID = pageID
    Parse.history.navigate(pageID, true);
    if pageID is 'login' or pageID is 'signup'
      @emit Constants.stores.LOGIN_CHANGE
    else if pageID is 'profile'
      @emit Constants.stores.MENU_CHANGE
    else
      @emit Constants.stores.MENU_CHANGE
    # TODO: stash currentPageID in Parse or localStorage and
    #   auto load previous app state when user returns to app.

  _loadCard: (cardId, peggeeId) ->
#    console.log cardId, peggeeId
    @_currentPageID = 'review'
    Parse.history.navigate(@_currentPageID, true);
    @emit Constants.stores.MENU_CHANGE

  _loadLink: (cardId, peggeeId) ->
    @_currentPageID = 'review'
    console.log cardId, peggeeId
#    @emit Constants.stores.MENU_CHANGE

#    @emit Constants.

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
    when Constants.actions.LOAD_LINK
      appstate._loadLink action.cardId, action.peggeeId
    when Constants.actions.CARD_SELECT
      appstate._loadCard action.cardId, action.peggeeId


module.exports = appstate
