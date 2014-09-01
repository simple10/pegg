EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'

Mood = Parse.Object.extend 'Mood'


class MoodStore extends EventEmitter
  _moods: null

#  _getMoodQuery: ->
#    new Parse.Query Mood

  fetch: ->
    query = new Parse.Query Mood
    query.equalTo 'live', true
    query.find
      success: (results) =>
        @_moods = results
        @emit Constants.stores.CHANGE
      error: (error) ->
        console.log "Error: #{error.code} #{error.message}"

  getMoods: ->
    @_moods

moods = new MoodStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to MoodStore
  switch action.actionType
    when Constants.actions.MOOD_FETCH
      moods.fetch


module.exports = moods
