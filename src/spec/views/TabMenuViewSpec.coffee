TabMenuView = require 'views/TabMenuView'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy


describe 'TabMenuView', ->
  beforeEach ->
    @model = [
      {pageID: '1', title: 'first', iconUrl: 'images/peggboard_medium.png'}
      {pageID: '2', title: 'second', iconUrl: 'images/newcard_medium.png'}
    ]

    @view = new TabMenuView
      count: 5
      model: @model

  it 'view should have tabs', ->
    expect(@view.tabs).to.have.length(2)

  it 'tabs should have page ids', ->
    expect(@view.tabs[0].getID()).to.equal @model[0].pageID

  it 'tabs should fill window width', ->
    expect(window.innerWidth).to.equal @view.tabs[0].options.width * @model.length

  xit 'tabs should have icons', ->


  #@surface = new Surface()
  #expect(@view.addTab).to.be.a 'function'
  #@view.surface.should.be.a(@surface)
