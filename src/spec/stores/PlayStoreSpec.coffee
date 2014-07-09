PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
Parse = require 'Parse'
helper = require '../helpers/Common'
expect = helper.expect
spy = helper.spy



describe 'PlayStore', ->
  beforeEach ->
    @playStore = PlayStore
    @playStore.load [
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

  it 'exists', ->
    expect(@playStore).to.exist

  it 'has a card set', ->
    expect(@playStore._cardSet).to.exist

  context 'Game', ->
    beforeEach ->
      @stage0 = @playStore._game._stages[0]
      @stage1 = @playStore._game._stages[1]

    it 'assigns the stages "_stages"', ->
      expect(@stage0._part.type).to.equal 'pref'
      expect(@stage0._part.size).to.equal 3

      expect(@stage1._part.type).to.equal 'pegg'
      expect(@stage1._part.size).to.equal 4

    it 'calls correct method on loadStage', ->
      fetch = @stage0._fetchPrefCards = spy()
      @playStore._game.loadStage()
      expect(fetch).to.have.been.calledWith 3

#  context 'Stage', ->
