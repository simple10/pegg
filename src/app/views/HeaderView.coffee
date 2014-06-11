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

###
# Events:
# toggleMenu
# logout
###
class HeaderView extends View
  title: 'Pegg'
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
      size: [55, 40]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/mark_tiny.png'
    @title = new Surface
      content: page
      classes: ["#{@cssPrefix}__title"]
    userImage = new ImageSurface
      size: [@options.height, @options.height]
      content: UserStore.getUser().get('avatar_url')
      class: ["#{@cssPrefix}__profilePic"]
      properties:
        borderRadius: "#{@options.height-15}px"
        padding: "10px"
    userImage.on "click", ->
      UserActions.logout()
    @add @background
    @add new Modifier
      origin: [0, 0]
      transform: Transform.multiply(
        Transform.inFront
        Transform.translate 10, 10
      )
    .add @logo
    @add new Modifier
      transform: Transform.translate 0, 10
    .add @title
    @add new Modifier
      origin: [1, 0]
      align: [1, 0]
    .add userImage


  initEvents: ->
    @logo.on 'click', =>
      @_eventOutput.emit 'toggleMenu'

  change: (page) ->
    @background.setClasses(["#{@cssPrefix}__background", "#{@cssPrefix}__background--#{page}"])
    @title.setContent page


module.exports = HeaderView
