EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
DB = require 'stores/helpers/ParseBackend'



class ActivityStore extends EventEmitter
  _activity: []

  _fetchActivities: (page) ->

    DB.getActivity(page, (results) =>
      if results
        @_activity = results
        @emit Constants.stores.ACTIVITY_CHANGE
    )

  getActivity: ->
    @_activity

activity = new ActivityStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.LOAD_ACTIVITY
      activity._fetchActivities action.page


module.exports = activity
