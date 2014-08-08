require './scss/profile.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'
Constants = require 'constants/PeggConstants'

Utils = require 'lib/Utils'
PrefBoardView = require 'views/PrefBoardView'

class ProfileView extends View
  @DEFAULT_OPTIONS:
    headerHeight: 50,
    profileContainerWidth: Utils.getViewportWidth()
    profileContainerHeight: Utils.getViewportHeight()
    profileContainerRatio: 2/5
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight()
    transition:
      duration: 500
      curve: Easing.outExpo

  constructor: (options) ->
    super options
    

    # set profileContainerHeight based off headerHeight and ratio
    @.setOptions
      profileContainerHeight: (Utils.getViewportHeight() - @options.headerHeight) * @options.profileContainerRatio

    @init()
    @initListeners()

  initListeners: ->
    UserStore.on Constants.stores.LOGIN_CHANGE, @_loadUser
    UserStore.on Constants.stores.PREF_IMAGES_CHANGE, @_loadImages

  init: ->
    @picContainer = new ContainerSurface
      size: [@options.profileContainerWidth, @options.profileContainerHeight]
      classes: ['profilePic']
      properties:
        overflow: 'hidden'
    @pic = new ImageSurface
      size: [ @options.width, @options.width]
      content: UserStore.getAvatar 'height=300&type=normal&width=300'
      classes: ['profile__pic']
    picMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
      # transform: Transform.translate 0, 150, -1
#    @pic.on 'click', ((picMod) =>
#      picMod.setTransform Transform.translate(0, 200, -1),
#        @options.transition
#    ).bind @, picMod
    @name = new Surface
      size: [270, 35]
      classes: ['profile__name__box']
      content: "#{UserStore.getName("first")}'s <strong>profile</strong>"
    nameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 1]
    logout = new Surface
      size: [ 200 , 50 ]
      content: 'Logout'
      classes: ['profile__logout__button']
    logoutMod = new StateModifier
      align: [0.5, 0.32]
      origin: [0.5, 0]
    logout.on 'click', ->
      UserStore.logout()

    @prefBoardMod = new StateModifier
      align: [0.5, 0.4]
      origin: [0.5, 0]
    @prefBoard = new PrefBoardView
      width: Utils.getViewportWidth()
      height: (Utils.getViewportHeight() - @options.headerHeight) * (1 - @options.profileContainerRatio)
      gutter: 5

    @picContainer.add @pic
    # @picContainer.add(@nameMod).add @name
    @add(picMod).add @picContainer
    @add(nameMod).add @name
    @add(logoutMod).add logout
    @add(@prefBoardMod).add @prefBoard

    # picMod.setAlign [0.5, -0.5], {duration: 300, easing: Easing.linear}
    # logoutMod.setTransform Transform.translate(0, -200, 0), {duration: 800, easing: Easing.outBounce}
    nameMod.setTransform Transform.translate(0, 160, 0), {duration: 500, easing: Easing.outCubic}

  _loadUser: =>
    @pic.setContent UserStore.getAvatar 'height=300&type=normal&width=300'
    @name.setContent "#{UserStore.getName('first')}'s <strong>profile</strong>"

  _loadImages: =>
    @prefBoard.loadImages UserStore.getPrefImages()

module.exports = ProfileView
