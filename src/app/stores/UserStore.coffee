EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'

DB = require 'stores/helpers/ParseBackend'

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
            facebook_id: res.id
          ,
            wait: false
            error: ->
              debugger
            success: =>
              Parse.history.navigate('play')
              @emit Constants.stores.CHANGE
              @importFriends()
        )
        unless user.existed()
          console.log 'User signed up and logged in through Facebook!'
        else
          console.log 'User logged in through Facebook!'
      error: (user, error) =>
        console.log "UserStore.login Error: #{user} - #{error} "
        @emit Constants.stores.CHANGE
        Parse.User.logOut()
        FB.logout()

  subscribe: (email) ->
    Subscriber = Parse.Object.extend("Subscriber")
    subscriber = new Subscriber()
    subscriber.set "email", email
    subscriber.save null,
      success: (subscriber) =>
        @_subscribed = true
        @emit Constants.stores.SUBSCRIBE_PASS
        console.log "Subscriber created with objectId: #{subscriber.id}"
        return

      error: (subscriber, error) ->
        @_subscribed = false
        @emit Constants.stores.SUBSCRIBE_FAIL
        console.log "Failed to create subscriber, with error code: #{error.description}"
        return

  logout: ->
    FB.logout()
    Parse.User.logOut()
    @emit Constants.stores.CHANGE

  getUser: ->
    Parse.User.current()

  getName: (part) ->
    user = @getUser()
    if user?
      user.get "#{part}_name"
    else
      'not logged in'

  getAvatar: (params)->
    user = @getUser()
    if user?
      user.get('avatar_url') + "?#{params}"
    else
      'not logged in'

  getLoggedIn: ->
    if @getUser()
      return true
    else
      return false

  getPrefImages: ->
    user = @getUser()
    userId = user.id
    DB.getPrefImages userId, (images) =>
      @emit Constants.stores.PREF_IMAGES_CHANGE, images

  getSubscriptionStatus: ->
    return @_subscribed

  importFriends: ->
    Parse.Cloud.run 'importFriends', null,
      success: (success) ->
        console.log success
      error: (error) ->
        console.error error.message

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
