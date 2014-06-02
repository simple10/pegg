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
    before (done) ->
      context = @
      payload = {}

      listener1Done = false
      listener1 = ->
        AppDispatcher.waitFor [index2, index4], ->
          expect(context.listener2Done).to.equal true
          expect(context.listener3Done).to.equal true
          expect(context.listener4Done).to.equal true
          context.listener1Done = true
          done()
      index1 = AppDispatcher.register listener1

      listener2Done = false
      listener2 = ->
        AppDispatcher.waitFor [index3], ->
          expect(context.listener3Done).to.equal true
          context.listener2Done = true
      index2 = AppDispatcher.register listener2

      listener3Done = false
      listener3 = ->
        context.listener3Done = true
      index3 = AppDispatcher.register listener3

      listener4Done = false
      listener4 = ->
        AppDispatcher.waitFor [index3], ->
          expect(context.listener3Done).to.equal true
          context.listener4Done = true
      index4 = AppDispatcher.register listener4

      AppDispatcher.dispatch payload


    it 'waits with chained dependencies', ->
      expect(@listener1Done).to.equal true
      expect(@listener2Done).to.equal true
      expect(@listener3Done).to.equal true
      expect(@listener4Done).to.equal true



