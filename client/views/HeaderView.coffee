# TODO: use NavigationBar widget when it's fixed https://github.com/Famous/widgets/pull/1

View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'


class HeaderView extends View
  classes: ['header']
  title: 'PEGG'

  constructor: ->
    super
    @build()

  # Build view
  build: ->
    @view = new View

    @background = new Surface
      classes: @classes

    @logo = new ImageSurface
      size: [40, 40]
      content: 'images/famous_logo.png'

    @title = new Surface
      content: @title
      properties:
        'text-align': 'center'

    @view.add @background

    @view.add new Modifier
      transform: Transform.translate 10, 10, 0
      origin: [0, 0]
    .add @logo

    @view.add new Modifier
      transform: Transform.translate 0, 10, 0
      origin: [0.5, 0]
    .add @title

    @add @view


module.exports = HeaderView
