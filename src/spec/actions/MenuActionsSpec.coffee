NavActions = require 'actions/NavActions'
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions
helper = require 'spec/helpers/Common'
expect = helper.expect
spy = helper.spy

describe 'NavActions', ->

  describe '#selectMenuItem', ->
    xit 'dispatches MENU_SELECT', ->
      pageID = 'testPage'
      handleViewAction = spy()
      AppDispatcher.handleViewAction = handleViewAction
      NavActions.selectMenuItem(pageID)
      expect(handleViewAction).to.have.been.calledWith
        actionType: Constants.MENU_SELECT
        pageID: pageID

