PlayView = require 'views/PlayView'
CardView = require 'views/CardView'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

describe 'PlayView', ->
  beforeEach ->
    @view = new PlayView

  it 'should exist', ->
    expect(@view).to.exist



  it 'should have an empty set of cards', ->
    expect(@view.cards).to.exist
    expect(@view.cards).to.have.length(0)



  it 'should load a set of cards', ->
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

