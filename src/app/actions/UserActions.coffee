AppDispatcher = require 'dispatchers/AppDispatcher'
Constants = require 'constants/PeggConstants'

UserActions =
  login: ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.USER_LOGIN

  logout: ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.USER_LOGOUT

  subscribe: (email) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.SUBSCRIBER_SUBMIT
      email: email

module.exports = UserActions
