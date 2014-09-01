rewire = require 'rewire'
MoodStore = rewire 'stores/MoodStore'
Constants = require 'constants/PeggConstants'
Parse = require 'Parse'
helper = require '../helpers/Common'
expect = helper.expect
spy = helper.spy


# Mock Parse.Query 'Mood'
#Mood = Parse.Object.extend 'Mood'
#MoodQuery = new Parse.Query Mood
#MoodQuery.find = (options) ->
#  options.success 'dummy'

Parse.find = (options) ->
  options.success 'dummy'

MoodStore.__set__ 'Parse', Parse

describe 'MoodStore', ->
  beforeEach ->
    @moodStore = MoodStore
#    @moodStore._getMoodQuery = ->
#      MoodQuery

  it 'exists', ->
    expect(@moodStore).to.exist

  it 'has a fetch function', ->
    expect(@moodStore.fetch).to.exist

  it 'has a getMoods function', ->
    expect(@moodStore.getMoods).to.exist

  it 'does not have moods until fetched', ->
    expect(@moodStore.getMoods()).to.be.a('null')

  it 'has moods after fetching', ->
    @moodStore.fetch()
    expect(@moodStore.getMoods()).to.not.be.a('null')

  it 'emits change after fetching data', (done) ->
    @moodStore.on Constants.stores.CHANGE, ->
      done()
    @moodStore.fetch()
