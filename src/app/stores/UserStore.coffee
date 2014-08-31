EventEmitter = require 'famous/core/EventEmitter'
Constants = require 'constants/PeggConstants'
AppDispatcher = require 'dispatchers/AppDispatcher'
Parse = require 'Parse'
Utils = require 'lib/Utils'
Config = require('Config').public

DB = require 'stores/helpers/ParseBackend'
NavActions = require 'actions/NavActions'

class UserStore extends EventEmitter
  _subscribed: false
  _images: []

  login: ->
    # http://stackoverflow.com/questions/16843116/facebook-oauth-unsupported-in-chrome-on-ios
    clientId = Config.facebook.appId
    redirectUri = Config.facebook.redirectUrl
    permissionUrl = "https://m.facebook.com/dialog/oauth?client_id=#{clientId}&redirect_uri=#{redirectUri}&scope=email,public_profile&response_type=token"
    window.location = permissionUrl


  auth: (res) ->
    console.log res
    access_token = Utils.parseQueryString res, 'access_token'
    params = "access_token=#{access_token}"
    future = new Date().addDays Config.facebook.expirationDays
    expirationDate = future.toISOString();

    Utils.getAjax("https://graph.facebook.com/me", params, (res) =>
      userData = JSON.parse res
      authData =
        expiration_date: expirationDate
        id: userData.id
        access_token: access_token
      @_loginParse authData
    )

  _loginParse: (authData) ->
    Parse.FacebookUtils.logIn authData,
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
              @emit Constants.stores.CHANGE
              NavActions.login()
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

  load: (filter) ->
    filter = filter || null
#    DB.getPrefImages @getUser().id, filter, (images) =>
#      @_images = images
#      @emit Constants.stores.PREF_IMAGES_CHANGE

    DB.getProfileActivity @getUser().id, filter, (activity) =>
      @_activity = activity
      @emit Constants.stores.PROFILE_ACTIVITY_CHANGE

    @emit Constants.stores.CHANGE

  logout: ->
    FB.logout()
    Parse.User.logOut()
    @emit Constants.stores.LOGIN_CHANGE

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
      'images/Unicorn_Cosmic1@2x.png'

  getLoggedIn: ->
    if @getUser()
      return true
    else
      return false

  getPrefImages: ->
    @_images

  getProfileActivity: ->
    @_activity

  getSubscriptionStatus: ->
    return @_subscribed

  importFriends: ->
    Parse.Cloud.run 'importFriends', null,
      success: (success) ->
        console.log success
      error: (error) ->
        console.error error.message

user = new UserStore


# http://stackoverflow.com/questions/11197668/fb-login-broken-flow-for-ios-webapp
#    isMobile = false
#    try
#      isMobile = (window.location.href is top.location.href and window.location.href.indexOf("/mobile/") isnt -1)
#    unless isMobile
#      @_loginParse null
#    else
#    if navigator.userAgent.match('CriOS')

# Register callback with AppDispatcher to be notified of events
AppDispatcher.register (payload) ->
  action = payload.action

  # Pay attention to events relevant to PlayStore
  switch action.actionType
    when Constants.actions.USER_LOGIN
      user.login()
    when Constants.actions.USER_LOGOUT
      user.logout()
    when Constants.actions.USER_LOAD
      user.load()
    when Constants.actions.FILTER_PREFS
      user.load action.filter
    when Constants.actions.SUBSCRIBER_SUBMIT
      user.subscribe action.email
    when Constants.actions.USER_AUTH
      user.auth action.code


module.exports = user
