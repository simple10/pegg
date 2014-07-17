EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'

Pegg = Parse.Object.extend 'Pegg'


class ActivityStore extends EventEmitter
  _activity: null

  _fetchActivities: (page) ->
    # TODO: implement pagination
    peggQuery = new Parse.Query Pegg
    peggQuery.include 'card'
    peggQuery.include 'answer'
    peggQuery.include 'peggee'
    peggQuery.find
      success: (results) =>
        @_activity = results
        # TODO: process the results from Parse
        @emit Constants.stores.ACTIVITY_CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

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
