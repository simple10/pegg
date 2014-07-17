PlayView = require 'views/PlayView'
PlayViewLayout = require 'views/layouts/mobile/PlayViewLayout'
CardView = require 'views/CardView'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

describe 'PlayView', ->
  beforeEach ->
    @view = new PlayView PlayViewLayout
    @view.loadCards = ->
      @cardViews = []

  it 'should exist', ->
    expect(@view).to.exist

  it 'should populate cardViews on loadCards', ->
    expect(@view.cardViews).to.not.exist
    @view.loadCards()
    expect(@view.cardViews).to.exist

  xit 'should load a set of cards', ->
    cards = [
      {id: 1, question: "What's the meaning of life?", answer: "42"}
      {id: 2, question: "What's lies in the middle of meaning?", answer: "3"}
    ]
    @view.load cards
    expect(@view.cards).to.have.length(2)


  xit 'should create a CardView for each card', ->
    newCard = CardView.constructor = spy()
    cards = [
      {id: 1, question: "What's the meaning of life?", answer: "42"}
    ]
    @view.load cards
    expect(newCard).to.have.been.calledWith
      question: cards[0].question
      answer: cards[0].answer


