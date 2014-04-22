# TODO: use NavigationBar widget when it's fixed https://github.com/Famous/widgets/pull/1

View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'


class HeaderView extends View
  title: 'PEGG'
  cssPrefix: 'header'

  constructor: ->
    super
    @build()

  # Build view
  build: ->
    @background = new Surface
      classes: ["#{@cssPrefix}__background"]

    @logo = new ImageSurface
      size: [40, 40]
      content: 'images/famous_logo.png'

    @title = new Surface
      content: @title
      classes: ["#{@cssPrefix}__title"]

    @add @background

    @add new Modifier
      origin: [0, 0]
      transform: Transform.translate 10, 10, 0
    .add @logo

    @add new Modifier
      transform: Transform.translate 0, 10, 0
    .add @title


module.exports = HeaderView
