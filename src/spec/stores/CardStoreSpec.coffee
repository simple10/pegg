{CardStore, Card} = require 'stores/CardStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy


describe 'CardStore', ->
  beforeEach ->
    @card_store = CardStore
    @card_store._cards = []

  it 'exists', ->
    expect(@card_store).to.exist

  it 'can get its cards', ->
    card = {name: 'hello', option: 'yes'}
    @card_store._cards = [card, card]
    expect(@card_store.getCards()).to.deep.equal [card, card]

  it 'can add a question to a card', ->
    card = new Card {author: 'Becca'}
    question = 'Are dragons real?'
    card.addQuestion question
    expect(card._question).to.equal question

  it 'can add answers to a card', ->
    card = new Card {author: 'Becca'}
    answers = ['Yes!!!', 'No, Virginia...']
    card.addAnswers answers...
    expect(card._answers).to.deep.equal answers

  context '#add', ->
    beforeEach ->
      @author = 'Becca'
      @question = 'Dragons???'
      data = {author: @author, question: @question}
      @card = @card_store.add data

    it 'adds a card to the card store', ->
      internal_card = @card_store._cards[0]
      expect(internal_card._author).to.equal @author
      expect(internal_card._question).to.equal @question

    it 'returns a Card object', ->
      expect(@card).to.be.an.instanceof Card

    it 'has the expected data', ->
      expect(@card._author).to.equal @author
      expect(@card._question).to.equal @question
