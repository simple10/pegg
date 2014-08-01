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
    PlayStore._loadGame fixtures.gameFlow, fixtures.scripts.fluffy_unicorn
    @stage0 = PlayStore._game._stages[0]
    @stage1 = PlayStore._game._stages[1]

  it 'exists', ->
    expect(PlayStore).to.exist

  # This is a meta test to ensure for ourselves that the PlayStore
  # singleton doesn't bleed over from test to test
  it 'is freshed up for each test', ->
    expect(PlayStore.asdf).to.not.exist
    PlayStore.asdf = 'asdf'

  it 'returns game\'s current cards', ->
    @stage0._fetchPrefCards = ->
      @_cardSet = fixtures.cardSet
    PlayStore._game.loadNextStage()
    cards = PlayStore.getCards()
    expect(cards).to.deep.equal fixtures.cardSet

  xit 'returns game\'s current status', ->

  xit 'returns choices for card', ->
    # @stage0._fetchChoices = (cardId) ->
    #   @cardSet['someId'].choices = fixtures.choices
    # choices = PlayStore.getChoices 'someId'
    # expect(choices).to.equal fixtures.choices

  xit 'returns comments for card', ->
    # playstore takes a card id and returns a set of comments
    comments = PlayStore.getComments 'card 1'
    expect(comments).to.equal fixtures.comments[0]
    # returns a different set of comments for a different card id
    comments = PlayStore.getComments 'card 2'
    expect(comments).to.equal fixtures.comments[1]

  it 'returns message for card type', ->
    # playstore has message instance
    expect(PlayStore._message).to.exist
    # gets message of the correct type
    message = PlayStore.getMessage 'win'
    expect(message).to.equal 'win 1'
    # returns next message of its type
    message = PlayStore.getMessage 'win'
    expect(message).to.equal 'win 2'
    # returns first message of a different type
    message = PlayStore.getMessage 'fail'
    expect(message).to.equal 'fail 1'

  context 'Game', ->
    it 'contains correct stages', ->
      expect(@stage0._part.type).to.equal 'pref'
      expect(@stage0._part.size).to.equal 3

      expect(@stage1._part.type).to.equal 'pegg'
      expect(@stage1._part.size).to.equal 4

    it 'calls correct method on loadNextStage', ->
      fetch = @stage0._fetchPrefCards = spy()
      PlayStore._game.loadNextStage()
      expect(fetch).to.have.been.calledWith 3


#  context 'Stage', ->
