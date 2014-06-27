PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
Parse = require 'Parse'
helper = require '../helpers/Common'
expect = helper.expect
spy = helper.spy

describe 'PlayStore', ->
  beforeEach ->
    @playStore = PlayStore

  it 'exists', ->
    expect(@playStore).to.exist

  it 'has a card set', ->
    expect(@playStore._cardSet).to.exist
