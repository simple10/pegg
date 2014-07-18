EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
UserStore = require 'stores/UserStore'
Parse = require 'Parse'

Pegg = Parse.Object.extend 'Pegg'


class ActivityStore extends EventEmitter
  _activity: []

  _fetchActivities: (page) ->
    # TODO: implement pagination
    peggQuery = new Parse.Query Pegg
    peggQuery.include 'card'
    peggQuery.include 'guess'
    peggQuery.include 'peggee'
    peggQuery.include 'user'
    peggQuery.find
      success: (results) =>
        for activity in results
          card = activity.get 'card'
          peggee = activity.get 'peggee'
          user = activity.get 'user'
          guess = activity.get 'guess'
          @_activity.push {
            pegger: user
            peggee: peggee
            question: card.get 'question'
            guess: guess.get 'text'
          }
        if results.length
          @emit Constants.stores.ACTIVITY_CHANGE
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message


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
