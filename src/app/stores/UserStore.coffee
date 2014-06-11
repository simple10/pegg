EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'

class UserStore extends EventEmitter
  _user: null
  _loggedIn: false

  login: ->
    Parse.FacebookUtils.logIn null,
      success: (user) =>
        @_loggedIn = true
        @_user = user
        user.save
          avatar_url: "https://graph.facebook.com/#{user.get('authData').facebook.id}/picture?type=square"
        unless user.existed()
          console.log 'User signed up and logged in through Facebook!'
        else
          console.log 'User logged in through Facebook!'
        @emit Constants.stores.CHANGE
      error: (user, error) =>
        console.log user + " - " + error
        @emit Constants.stores.CHANGE
        @_loggedIn = false
        Parse.User.logOut()

  logout: ->
    Parse.User.logOut()
    @emit Constants.stores.CHANGE
    @_loggedIn = false

  getUser: ->
    @_user

  getLoggedIn: ->
    if Parse.User.current()
      return true
    else
      return false

user = new UserStore


# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.USER_LOGIN
      user.login()
    when Constants.actions.USER_LOGOUT
      user.logout()

module.exports = user
