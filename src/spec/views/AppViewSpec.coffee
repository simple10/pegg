AppView = require 'views/AppView'
chai = require 'chai'

expect = chai.expect

describe 'AppView', ->
  beforeEach ->
    @view = new AppView()

  it 'creates HeaderFooterLayout and adds it to view', ->
    expect(@view.testtest).to.be.a 'function'
    expect(false).to.equal false
