AppDispatcher = require 'dispatchers/AppDispatcher'
helper = require 'spec/helpers/Common'
expect = helper.expect
spy = helper.spy


describe 'AppDispatcher', ->
  beforeEach ->
    # Reset AppDispatcher for each test
    AppDispatcher = new AppDispatcher.constructor

  describe '#dispatch', ->
    it 'sends actions to subscribers', ->
      listener = spy()
      AppDispatcher.register listener
      payload = {}
      AppDispatcher.dispatch payload
      expect(listener).to.have.been.calledOnce
      expect(listener).to.have.been.calledWith payload

  describe '#waitFor', ->
    it 'waits with chained dependencies', (done) ->
      payload = {}
      listener2Done = false
      listener3Done = false
      listener4Done = false

      listener1 = ->
        AppDispatcher.waitFor [index2, index4], ->
          expect(listener2Done).to.equal true
          expect(listener3Done).to.equal true
          expect(listener4Done).to.equal true
          done()
      index1 = AppDispatcher.register listener1

      listener2 = ->
        AppDispatcher.waitFor [index3], ->
          expect(listener3Done).to.equal true
          listener2Done = true
      index2 = AppDispatcher.register listener2

      listener3 = ->
        listener3Done = true
      index3 = AppDispatcher.register listener3

      listener4 = ->
        AppDispatcher.waitFor [index3], ->
          expect(listener3Done).to.equal true
          listener4Done = true
      index4 = AppDispatcher.register listener4

      AppDispatcher.dispatch payload


