PeggBoxView = require 'views/PeggBoxView'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy


describe 'PeggBoxView', ->
  beforeEach ->
    @model = [
      {itemID: '1', message: 'John pegged you back.', pic: 'images/peggboard_medium.png'}
      {itemID: '2', message: 'second', pic: 'images/newcard_medium.png'}
    ]

    @view = new PeggBoxView
      model: @model

  it 'should have items', ->
    expect(@view.items).to.have.length(2)
