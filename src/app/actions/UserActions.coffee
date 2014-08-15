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

  load: ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.USER_LOAD

  filterPrefs: (filter) ->
    AppDispatcher.handleViewAction
      actionType: Constants.actions.FILTER_PREFS
      filter: filter

module.exports = UserActions
