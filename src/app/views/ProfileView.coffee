require './scss/profile.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
UserStore = require 'stores/UserStore'
Constants = require 'constants/PeggConstants'

class ProfileView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth
    height: window.innerHeight
    transition:
      duration: 500
      curve: Easing.outExpo

  constructor: (options) ->
    super options
    UserStore.on Constants.stores.CHANGE, @_update
    @init()

  _update: =>
    @pic.setContent UserStore.getAvatar 'height=300&type=normal&width=300'
    @name.setContent "#{UserStore.getName('first')}'s <strong>profile</strong>"

  init: ->
    @pic = new ImageSurface
      size: [ @options.width, null]
      content: UserStore.getAvatar 'height=300&type=normal&width=300'
      classes: ["profile__pic"]
    picMod = new StateModifier
      align: [0.5, 1]
      origin: [0.5, 1]
      transform: Transform.translate 0, 100, -1
    @pic.on 'click', ((picMod) =>
      picMod.setTransform Transform.translate(0, 200, -1),
        @options.transition
    ).bind @, picMod
    @name = new Surface
      size: [220, 35]
      classes: ['profile__name__box']
      content: "#{UserStore.getName("first")}'s <strong>profile</strong>"
    nameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 1]
    logout = new Surface
      size: [ 200 , 50 ]
      content: "Logout"
      classes: ['profile__logout__button']
    logoutMod = new StateModifier
      align: [0.5, 1]
      origin: [0.5, 1]
    logout.on 'click', ->
      UserStore.logout()

    @add(picMod).add @pic
    @add(nameMod).add @name
    @add(logoutMod).add logout
    picMod.setAlign [0.5, -0.5], {duration: 300, easing: Easing.linear}
    logoutMod.setTransform Transform.translate(0, -200, 0), {duration: 800, easing: Easing.outBounce}
    nameMod.setTransform Transform.translate(0, 160, 0), {duration: 500, easing: Easing.outCubic}


module.exports = ProfileView
