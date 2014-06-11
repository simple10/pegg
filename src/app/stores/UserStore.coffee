EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'

class UserStore extends EventEmitter

  login: ->
    Parse.FacebookUtils.logIn null,
      success: (user) =>
        FB.api("/me", "get", (res) ->
          user.save
            avatar_url: "https://graph.facebook.com/#{user.get('authData').facebook.id}/picture?type=square"
            name: res.name
            gender: res.gender
        )
        unless user.existed()
          console.log 'User signed up and logged in through Facebook!'
        else
          console.log 'User logged in through Facebook!'
        @emit Constants.stores.CHANGE
      error: (user, error) =>
        console.log "UserStore.login Error: " + user + " - " + error
        @emit Constants.stores.CHANGE
        Parse.User.logOut()

  logout: ->
    Parse.User.logOut()
    @emit Constants.stores.CHANGE

  getUser: ->
    Parse.User.current()

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
