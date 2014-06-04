EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PeggBoxStore extends EventEmitter
  _nextSet: null

  fetchParse: (page) ->
    debugger
    Sets = Parse.Object.extend("Sets")
    query = new Parse.Query(Sets)
    query.exists "title"
    query.find
      success: (results) =>
        @_nextSet = results
        @emit Constants.stores.CHANGE
        console.log results
        i = 0
        while i < results.length
          object = results[i]
          console.log object
          i++
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  getNextSet: ->
    @_nextSet

peggbox = new PeggBoxStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PeggBoxStore
  switch action.actionType
    when Constants.actions.PEGGBOX_FETCH
      peggbox.fetchParse action.page


module.exports = peggbox
