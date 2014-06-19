EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class MoodStore extends EventEmitter
  _moods: null

  fetch: ->
    @_moods = "something"

  getMoods: ->
    @_moods

moods = new MoodStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to MoodStore
  switch action.actionType
    when Constants.actions.MOODS_FETCH
      moods.fetch


module.exports = moods
