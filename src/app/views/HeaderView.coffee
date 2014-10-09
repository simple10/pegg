# TODO: use NavigationBar widget when it's fixed https://github.com/Famous/widgets/pull/1

require './scss/header.scss'

View = require 'famous/src/core/View'
Utility = require 'famous/src/utilities/Utility'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier  = require 'famous/src/core/Modifier'
Transform = require 'famous/src/core/Transform'
UserActions = require 'actions/UserActions'
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'
Constants = require 'constants/PeggConstants'
NavActions = require 'actions/NavActions'
Easing = require 'famous/src/transitions/Easing'
Timer = require 'famous/src/utilities/Timer'
StateModifier = require 'famous/src/modifiers/StateModifier'

###
# Events:
# toggleMenu
# logout
###
class HeaderView extends View
  cssPrefix: 'header'
  height: 50

  constructor: ->
    super
    UserStore.on Constants.stores.CHANGE, @_update
    #AppStateStore.on Constants.stores.CHANGE, @_build
    @_build()
    @initEvents()

  # Build view
  _build: =>
    #page = AppStateStore.getCurrentPageID()
    #@background.setClasses ["#{@cssPrefix}__background", "#{@cssPrefix}__background--#{page}"]
    #@title.setContent page
    #if page isnt "profile" then page else ""
    @mainMod = new StateModifier
      transform: Transform.translate 0, 0, 10
    @background = new Surface
      classes: ["#{@cssPrefix}__background"]
    @menuIcon = new ImageSurface
      size: [30, 50]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/hamburger.svg'
    menuIconMod = new Modifier
      transform: Transform.translate 8, 0, 0
    @logo = new ImageSurface
      size: [40, 40]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/home.svg'
    logoMod = new StateModifier
      transform: Transform.translate 10, 10, 0
    @pic = new ImageSurface
      size: [@options.height, @options.height]
      classes: ["#{@cssPrefix}__profilePic"]
      content: UserStore.getAvatar 'type=square'
      properties:
        borderRadius: "#{@options.height-10}px"
        padding: '10px'
    picMod = new Modifier
      origin: [1, 0]
      align: [1, 0]
      transform: Transform.translate -8, 0, 0
    @me = new Surface
      classes: ["#{@cssPrefix}__text"]
      content: 'Me'
      size: [50, 50]
    meMod = new Modifier
      origin: [1, 0]
      align: [1, 0]
      transform: Transform.translate -28, 16, 11

    node = @add @mainMod
    node.add @background
#    node.add(menuIconMod).add @menuIcon
#    node.add(logoMod).add @logo
#    node.add( picMod).add @pic
#    node.add(meMod).add @me


  _update: =>
    @pic.setContent UserStore.getAvatar 'type=square'


  initEvents: ->
    @logo.on 'click', =>
      @_eventOutput.emit 'toggleMenu'
    @menuIcon.on 'click', =>
      @_eventOutput.emit 'toggleMenu'
    @pic.on 'click', ->
      NavActions.selectMenuItem 'profile'
    @me.on 'click', ->
      NavActions.selectMenuItem 'profile'


module.exports = HeaderView
