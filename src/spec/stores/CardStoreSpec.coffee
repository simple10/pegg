CardStore = require 'stores/CardStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

# Mocks
GetUser = -> 'Augustin'

describe 'CardStore', ->
  beforeEach ->
    @card_store = CardStore
    @card_store._getUser = -> GetUser

  it 'exists', ->
    expect(@card_store).to.exist

  it 'can get its card', ->
    author = 'Becca'
    question = 'Which dress should I wear?'
    answers = ['That one.', 'Don\'t care', 'Whatever you like.', 'The other one.']
    categories = ['bored', 'fashion']
    @card_store._author = author
    @card_store._question = question
    @card_store._answers = answers
    @card_store._categories = categories
    expect(@card_store.getCard()).to.deep.equal {author: author, question: question, answers: answers, categories: categories}

  it 'can add a question to its card', ->
    question = 'Are dragons real?'
    @card_store.addQuestion question
    expect(@card_store._question).to.equal question

  it 'can add answers to a card', ->
    answers = ['Yes!!!', 'No, Virginia...']
    @card_store.addAnswers answers
    expect(@card_store._answers).to.deep.equal answers

  xcontext '#add', ->
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


