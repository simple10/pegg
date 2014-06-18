EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'

class UserStore extends EventEmitter
  _subscribed: false

  login: ->
    Parse.FacebookUtils.logIn null,
      success: (user) =>
        FB.api("/me", "get", (res) =>
          user.save
            avatar_url: "https://graph.facebook.com/#{user.get('authData').facebook.id}/picture"
            first_name: res.first_name
            last_name: res.last_name
            gender: res.gender
          ,
            wait: false
            error: ->
              debugger
            success: =>
              @emit Constants.stores.CHANGE
        )
        unless user.existed()
          console.log 'User signed up and logged in through Facebook!'
        else
          console.log 'User logged in through Facebook!'

      error: (user, error) =>
        console.log "UserStore.login Error: " + user + " - " + error
        @emit Constants.stores.CHANGE
        Parse.User.logOut()

  subscribe: (email) ->
    Subscriber = Parse.Object.extend("Subscriber")
    subscriber = new Subscriber()
    subscriber.set "email", email
    subscriber.save null,
      success: (subscriber) =>
        @emit Constants.stores.SUBSCRIBE_PASS
        @_subscribed = true
        console.log "Subscriber created with objectId: " + subscriber.id
        return

      error: (subscriber, error) ->
        @emit Constants.stores.SUBSCRIBE_FAIL
        @_subscribed = false
        console.log "Failed to create subscriber, with error code: " + error.description
        return


  logout: ->
    Parse.User.logOut()
    @emit Constants.stores.CHANGE

  getUser: ->
    Parse.User.current()

  getName: (part) ->
    if Parse.User.current()
      return Parse.User.current().get("#{part}_name")

  getAvatar: (type)->
    if Parse.User.current()
      return Parse.User.current().get('avatar_url') + "?type=#{type}"

  getLoggedIn: ->
    if Parse.User.current()
      return true
    else
      return false

  getSubscriptionStatus: ->
    return @_subscribed

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
    when Constants.actions.SUBSCRIBER_SUBMIT
      user.subscribe action.email

module.exports = user
