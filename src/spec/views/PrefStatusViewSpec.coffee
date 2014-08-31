PrefStatusView = require 'views/PrefStatusView'
expect = require('spec/helpers/Common').expect


describe 'PrefStatusView', ->
  beforeEach ->
    @view = new PrefStatusView

  it 'initializes', ->
    expect(@view).to.exist
  # TODO: expect @view.init() to have been called

  xit 'has users profile picture', ->
    expect(@view._userPhoto).to.equal 'not logged in'
  # TODO: mock UserStore

  xit 'has users name', ->
    expect(@view._userName).to.equal 'not logged in'

  it 'loads json data', ->
    expect(@view.load).to.be.a.function

  xit 'has questions', ->
    expect("implemented").to.equal true

  xit 'has choices for each question', ->
    expect("implemented").to.equal true

  xit 'has percentages for each choice', ->
    expect("implemented").to.equal true

  xit 'emits nextStage', ->
    expect("implemented").to.equal true

  xit 'emits share', ->
    expect("implemented").to.equal true

