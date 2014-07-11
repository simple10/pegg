PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
Parse = require 'Parse'
helper = require '../helpers/Common'
expect = helper.expect
spy = helper.spy

fixtures = {
  gameFlow: [
    [      # stage 1
      {
        type: 'pref'
        size: 3
      }
      {
        type: 'message_next_friend'
      }
    ]
    [      # stage 2
      {
        type: 'pegg'
        size: 4
      }
      {
        type: 'status_friend_ranking'
      }
    ]
  ]
  cardSet: {
    'someId': {
      firstName: 'asdf'
      pic: 'asdf'
      question: 'asdf'
      choices: null
    }
  }
  choices: [
    {
      id: 'asdf'
      text: 'asdf'
      image: 'asdf'
    }
  ]
  scripts: {
    fluffy_unicorn: {
      fail: [
        'fail 1'
        'fail 2'
      ]
      win: [
        'win 1'
        'win 2'
      ]
    }
  }
}

describe 'PlayStore', ->
  beforeEach ->
    @playStore = PlayStore
    @playStore.loadGame fixtures.gameFlow
    @playStore.loadScript fixtures.scripts.fluffy_unicorn
    @stage0 = @playStore._game._stages[0]
    @stage1 = @playStore._game._stages[1]

  it 'exists', ->
    expect(@playStore).to.exist

  it 'returns game\'s current cards', ->
    @stage0._fetchPrefCards = ->
      @cardSet = fixtures.cardSet
    @playStore._game.loadStage()
    cards = @playStore.getCards()
    expect(cards).to.deep.equal fixtures.cardSet

  xit 'returns game\'s current status', ->

  xit 'returns choices for card', ->
    # @stage0._fetchChoices = (cardId) ->
    #   @cardSet['someId'].choices = fixtures.choices
    # choices = @playStore.getChoices 'someId'
    # expect(choices).to.equal fixtures.choices

  xit 'returns comments for card', ->
    # playstore takes a card id and returns a set of comments
    comments = @playStore.getComments 'card 1'
    expect(comments).to.equal fixtures.comments[0]
    # returns a different set of comments for a different card id
    comments = @playStore.getComments 'card 2'
    expect(comments).to.equal fixtures.comments[1]

  it 'returns message for card type', ->
    # playstore has message instance
    expect(@playStore._message).to.exist
    # gets message of the correct type
    message = @playStore.getMessage 'win'
    expect(message).to.equal 'win 1'
    # returns next message of its type
    message = @playStore.getMessage 'win'
    expect(message).to.equal 'win 2'
    # returns first message of a different type
    message = @playStore.getMessage 'fail'
    expect(message).to.equal 'fail 1'

  context 'Game', ->
    it 'contains correct stages', ->
      expect(@stage0._part.type).to.equal 'pref'
      expect(@stage0._part.size).to.equal 3

      expect(@stage1._part.type).to.equal 'pegg'
      expect(@stage1._part.size).to.equal 4

    it 'calls correct method on loadStage', ->
      fetch = @stage0._fetchPrefCards = spy()
      @playStore._game.loadStage()
      expect(fetch).to.have.been.calledWith 3


#  context 'Stage', ->
