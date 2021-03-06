EventEmitter = require 'famous/src/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PeggBoxStore extends EventEmitter
  _activity: null

  fetchParse: (page) ->
    # TODO: implement pagination
    PeggBox = Parse.Object.extend("PeggBox")
    query = new Parse.Query(PeggBox)
    query.equalTo "userId", 1
    query.find
      success: (results) =>
        @_activity = results
        # TODO: process the results from Parse
        @emit Constants.stores.CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  getActivity: ->
    @_activity

peggbox = new PeggBoxStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.PEGGBOX_FETCH
      peggbox.fetchParse action.page


module.exports = peggbox
