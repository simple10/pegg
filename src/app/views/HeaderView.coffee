# TODO: use NavigationBar widget when it's fixed https://github.com/Famous/widgets/pull/1

require './scss/header.scss'

View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
UserActions = require 'actions/UserActions'
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'
Constants = require 'constants/PeggConstants'
NavActions = require 'actions/NavActions'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'
StateModifier = require 'famous/modifiers/StateModifier'

###
# Events:
# toggleMenu
# logout
###
class HeaderView extends View
  cssPrefix: 'header'
  height: null

  constructor: ->
    super
    UserStore.on Constants.stores.LOGIN_CHANGE, @_update
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
      transform: Transform.translate(0,0,10)
    @background = new Surface
      classes: ["#{@cssPrefix}__background"]
    @logo = new ImageSurface
      size: [150, 50]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/pegg_logo-small.png'
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

    node = @add @mainMod
    node.add @background
    node.add new Modifier
      origin: [0, 0]
    .add @logo
    node.add(picMod).add @pic

  _update: =>
    @pic.setContent UserStore.getAvatar 'type=square'


  initEvents: ->
    @logo.on 'click', =>
      @_eventOutput.emit 'toggleMenu'
    @pic.on 'click', ->
      NavActions.selectMenuItem 'profile'


module.exports = HeaderView
