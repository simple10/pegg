Promise = require 'bluebird'

# Share callbacks and promises across the app regardless of Dispatcher instance.

class Dispatcher
  _callbacks: []
  _promises: []

  constructor: ->
    @_callbacks = []
    @_promises = []

  ###
  Register a Store's callback so that it may be invoked by an action.
  @param {function} callback The callback to be registered.
  @return {number} The index of the callback within the _callbacks array.
  ###
  register: (callback) ->
    @_callbacks.push callback
    @_callbacks.length - 1

  ###
  dispatch
  @param  {object} payload The data from the action.
  ###
  dispatch: (payload) ->
    # First create array of promises for callbacks to reference.
    resolves = []
    rejects = []
    @_promises = @_callbacks.map (_, i) ->
      new Promise (resolve, reject) ->
        resolves[i] = resolve
        rejects[i] = reject

    # Dispatch to callbacks and resolve/reject promises.
    @_callbacks.forEach (callback, i) ->
      # Callback can return an obj, to resolve, or a promise, to chain.
      # See waitFor() for why this might be useful.
      Promise.resolve(callback payload).then ->
        resolves[i] payload
      , ->
        rejects[i] new Error 'Dispatcher callback unsuccessful'

    @_promises = []


  ###
  Allows a store to wait for the registered callbacks of other stores
  to get invoked before its own does.
  This function is not used by this TodoMVC example application, but
  it is very useful in a larger, more complex application.

  Example usage where StoreB waits for StoreA:

  class StoreA extends EventEmitter
    dispatchIndex: Dispatcher.register (payload) ->
      // switch statement with lots of cases

  class StoreB extends EventEmitter
    dispatchIndex: Dispatcher.register (payload) ->
      switch payload.action.actionType
        when MyConstants.FOO_ACTION
          Dispatcher.waitFor [StoreA.dispatchIndex], ->
            // Do stuff only after StoreA's callback returns.

  It should be noted that if StoreB waits for StoreA, and StoreA waits for
  StoreB, a circular dependency will occur, but no error will be thrown.
  A more robust Dispatcher would issue a warning in this scenario.
  ###
  waitFor: (promiseIndexes, callback) ->
    selectedPromises = promiseIndexes.map (index) =>
      @_promises[index]
    Promise.all(selectedPromises).then callback


module.exports = Dispatcher

