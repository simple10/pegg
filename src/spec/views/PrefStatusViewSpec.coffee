PrefStatusView = require 'views/PrefStatusView'
expect = require('spec/helpers/Common').expect


describe 'PrefStatusView', ->
  beforeEach ->
    @view = new PrefStatusView

  it 'initializes', ->
    expect(@view).to.exist
  # TODO: expect @view.init() to have been called

  it 'has users profile picture', ->
    expect(@view._userPhoto).to.equal 'not logged in'
  # TODO: mock UserStore

  it 'has users name', ->
    expect(@view._userName).to.equal 'not logged in'

  it 'loads json data', ->
    expect(@view.load).to.be.a.function

  it 'has questions', ->
    expect("implemented").to.equal true

  it 'has choices for each question', ->
    expect("implemented").to.equal true

  it 'has percentages for each choice', ->
    expect("implemented").to.equal true

  it 'emits nextStage', ->
    expect("implemented").to.equal true

  it 'emits share', ->
    expect("implemented").to.equal true

