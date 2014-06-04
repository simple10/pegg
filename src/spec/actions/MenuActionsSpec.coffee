MenuActions = require 'actions/MenuActions'
AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require('constants/PeggConstants').actions
helper = require 'spec/helpers/Common'
expect = helper.expect
spy = helper.spy

describe 'MenuActions', ->

  describe '#selectMenuItem', ->
    it 'dispatches MENU_SELECT', ->
      pageID = 'testPage'
      handleViewAction = spy()
      AppDispatcher.handleViewAction = handleViewAction
      MenuActions.selectMenuItem(pageID)
      expect(handleViewAction).to.have.been.calledWith
        actionType: Constants.MENU_SELECT
        pageID: pageID

