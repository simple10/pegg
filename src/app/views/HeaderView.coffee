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
MenuActions = require 'actions/MenuActions'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'

###
# Events:
# toggleMenu
# logout
###
class HeaderView extends View
  @DEFAULT_OPTIONS:
    title: 'play'
  cssPrefix: 'header'
  height: null

  constructor: ->
    super
    @build(@options.title)
    @initEvents()

  # Build view
  build: (page) ->
    @background = new Surface
      classes: ["#{@cssPrefix}__background", "#{@cssPrefix}__background--#{page}"]
    @logo = new ImageSurface
      size: [130, 59]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/pegg_logo-small.png'
    #@title = new Surface
    #  content: page
    #  classes: ["#{@cssPrefix}__title"]
    pic = new ImageSurface
      size: [@options.height, @options.height]
      content: UserStore.getAvatar 'type=square'
      classes: ["#{@cssPrefix}__profilePic"]
      properties:
        borderRadius: "#{@options.height-15}px"
        padding: "10px"
    picMod = new Modifier
      origin: [1, 0]
      align: [1, 0]
    pic.on "click", ((picMod) =>
      #picMod.setTransform Transform.scale(1, 0, 0),
      #  { duration: 800, curve: Easing.inOutBack }
      #Timer.after (=>
        MenuActions.selectMenuItem "profile"
      #), 20
    ).bind null, picMod
    @add @background
    @add new Modifier
      origin: [0, 0]
    .add @logo
    #@add new Modifier
    #  transform: Transform.translate 0, 10
    #.add @title
    @add(picMod).add pic


  initEvents: ->
    @logo.on 'click', =>
      @_eventOutput.emit 'toggleMenu'

  change: (page) ->
    #@background.setClasses ["#{@cssPrefix}__background", "#{@cssPrefix}__background--#{page}"]
    #@title.setContent page
    #if page isnt "profile" then page else ""


module.exports = HeaderView
