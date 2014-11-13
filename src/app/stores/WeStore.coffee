EventEmitter = require 'famous/src/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'



class WeStore extends EventEmitter
  _activity: []
  _insights: []

  _fetchActivities: (page) ->
    userId = UserStore.getUser().id
    DB.getActivity(userId, page, (results) =>
      if results?
        @_activity = results
        @emit Constants.stores.ACTIVITY_CHANGE
    )

  _fetchTopPeggers: (peggeeId) ->
    DB.getTopPeggers peggeeId
      .then (results) =>
        if results?
          @_insights = results
          @emit Constants.stores.INSIGHTS_LOADED

  getActivity: ->
    @_activity

  getInsights: ->
    @_insights

weStore = new WeStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.LOAD_INSIGHTS
      weStore._fetchTopPeggers action.peggeeId
    when Constants.actions.LOAD_ACTIVITY
      weStore._fetchActivities action.pageId


module.exports = weStore
