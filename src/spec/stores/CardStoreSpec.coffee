{cardStore, Card} = require 'stores/CardStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy


describe 'CardStore', ->
  beforeEach ->
    @card_store = cardStore
    @card_store._cards = []

  it 'exists', ->
    expect(@card_store).to.exist

  xit 'can get its cards', ->
    card = {name: 'hello', option: 'yes'}
    @card_store._cards = [card, card]
    expect(@card_store.getCards()).to.deep.equal [card, card]

  xit 'can add a card', ->
    card = {name: 'hello', option: 'yes'}
    @card_store.add card
    expect(@card_store._cards).to.deep.equal [card]

  it 'can add a question to a card', ->
    card = new Card {author: 'Becca'}
    question = 'Are dragons real?'
    card.addQuestion question
    expect(card._question).to.equal question





