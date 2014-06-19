DeckStore = require 'stores/DeckStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

describe 'DeckStore', ->
  beforeEach ->
    @decks = DeckStore

  it 'should exist', ->
    expect(@decks).to.exist
