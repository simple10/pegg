MoodStore = require 'stores/MoodStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

describe 'MoodStore', ->
  beforeEach ->
    @moodStore = MoodStore

  it 'should exist', ->
    expect(@moodStore).to.exist

  it 'should have a fetch function', ->
    expect(@moodStore.fetch).to.exist

  it 'should have a getMoods function', ->
    expect(@moodStore.getMoods).to.exist

  it 'should not have moods until fetched', ->
    expect(@moodStore.getMoods()).to.be.a('null');
    @moodStore.fetch()
    expect(@moodStore.getMoods()).to.not.be.a('null');
