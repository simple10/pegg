# TODO: use NavigationBar widget when it's fixed https://github.com/Famous/widgets/pull/1

require './header.scss'

View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'


class HeaderView extends View
  title: 'Pegg'
  cssPrefix: 'header'

  constructor: ->
    super
    @build()
    @initEvents()

  # Build view
  build: ->
    @background = new Surface
      classes: ["#{@cssPrefix}__background"]

    @logo = new ImageSurface
      size: [55, 40]
      classes: ["#{@cssPrefix}__logo"]
      content: 'images/mark_tiny.png'

    @title = new Surface
      content: @title
      classes: ["#{@cssPrefix}__title"]

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

  initEvents: ->
    @logo.on 'click', =>
      @_eventOutput.emit 'toggleMenu'

module.exports = HeaderView
