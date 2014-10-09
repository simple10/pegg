TabMenuView = require 'views/TabMenuView'
helper = require '../helpers/Common'
Timer = require 'famous/src/utilities/Timer'
expect = helper.expect
should = helper.should
spy = helper.spy

Utils = require 'lib/Utils'

describe 'TabMenuView', ->
  beforeEach ->
    @model = [
      {pageID: '1', title: 'first', iconUrl: 'images/peggboard_medium.png'}
      {pageID: '2', title: 'second', iconUrl: 'images/newcard_medium.png'}
    ]

    @view = new TabMenuView
      model: @model

  it 'view should have tabs', ->
    expect(@view.tabs).to.have.length(2)

  it 'tabs should have page ids', ->
    expect(@view.tabs[0].getID()).to.equal @model[0].pageID

  it 'tabs should fill window width', ->
    expect(Utils.getViewportWidth()).to.equal @view.tabs[0].options.width * @model.length
    expect(@view.tabs[1].options.xOffset).to.equal 1 / @model.length

  it 'tabs should show', ->
    @view.showTabs()
    Timer.setTimeout (->
      pos = @view.tabModifiers[0].getFinalTransform()
      console.log pos
      expect(pos[13]).to.equal 0
    ), 40

  it 'tabs should hide', ->
    @view.hideTabs()
    Timer.setTimeout (->
      pos = @view.tabModifiers[0].getFinalTransform()
      console.log pos
      expect(pos[13]).to.equal @view.options.tab.height
    ), 40




  #@surface = new Surface()
  #expect(@view.addTab).to.be.a 'function'
  #@view.surface.should.be.a(@surface)
