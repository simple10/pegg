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
    it 'assigns the stages "_stages"', ->
      expect(@playStore._game._stages[0]._part.type).to.equal 'pref'
      expect(@playStore._game._stages[0]._part.size).to.equal 3

      expect(@playStore._game._stages[1]._part.type).to.equal 'pegg'
      expect(@playStore._game._stages[1]._part.size).to.equal 4

    it 'calls correct method on loadStage', ->
      fetch = @playStore._fetchPrefCards() = spy()
      @playStore._game.loadStage()
      expect(fetch).to.have.been.calledWith 42
#        @playStore._game._stages[0]._part.size


#  context 'Stage', ->
#    it 'assigns the first part to "_part"', ->
#      expect(@stage._part).to.deep.equal {
#        type: 'pref'
#        size: 3
#      }

