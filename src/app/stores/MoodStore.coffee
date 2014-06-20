EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class MoodStore extends EventEmitter
  _moods: null

  fetch: ->
    Mood = Parse.Object.extend("Mood")
    query = new Parse.Query(Mood)
    query.equalTo "live", true
    query.find
      success: (results) =>
        console.log results
        @_moods = results
        @emit Constants.stores.CHANGE
        return
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        return

  getMoods: ->
    @_moods

moods = new MoodStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to MoodStore
  switch action.actionType
    when Constants.actions.GAME_FETCH
      moods.fetch


module.exports = moods
