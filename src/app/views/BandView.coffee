View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'


class BandView extends View
  @DEFAULT_OPTIONS:
    width: 400
    height: 100
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 32

  constructor: () ->
    super
    @createBackground()
    @createIcon()
    @createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      properties:
        backgroundColor: @options.color
        boxShadow: '0 0 1px ' + @options.color
    @add @background
    #@background.on 'click', =>
    #  @_eventOutput.emit 'toggleMenu'

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
      pointerEvents : 'none'
    @add @icon

  createTitle: ->
    @title = new Surface
      size: [true, true]
      content: @options.title
      properties:
        color: 'white'
        fontFamily: 'AvenirNextCondensed-DemiBold'
        fontSize: this.options.fontSize + 'px'
        textTransform: 'uppercase'
        pointerEvents : 'none'
    @add @title


module.exports = BandView
