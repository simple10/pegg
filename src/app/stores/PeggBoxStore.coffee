EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'


class PeggBoxStore extends EventEmitter
  _currentBox: null

  fetchParse: (pagination) ->
    # TODO: get set of peggbox from parse


  getPeggBox: ->
    @_currentPageID


peggbox = new PeggBoxStore

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to AppStateStore
  switch action.actionType
    when Constants.actions.PEGGBOX_FETCH
      peggbox.fetchParse action.page


module.exports = peggbox
