ActivityStore = require 'stores/ActivityStore'
helper = require '../helpers/Common'
expect = helper.expect
should = helper.should
spy = helper.spy

describe 'ActivityStore', ->

  it 'exists', ->
    expect(ActivityStore).to.exist

  it 'can get activity', ->
    data = 'not null'
    ActivityStore._activity = data
    expect(ActivityStore.getActivity()).to.equal data
