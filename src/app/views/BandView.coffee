View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'


class BandView extends View
  @DEFAULT_OPTIONS:
    # menu item identifier
    menuID: null
    width: 280
    height: 100
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 32

  constructor: ->
    super
    @createBackground()
    @createIcon()
    @createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      classes: ['menu__item', "menu__item--#{@options.menuID}"]
    @add @background
    @background.on 'click', =>
      @_eventOutput.emit 'selectMenuItem', @

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
    @add @icon

  createTitle: ->
    @title = new Surface
      size: [true, true]
      content: @options.title
      classes: ['menu__item__title']
    @add @title

  getID: ->
    @options.menuID

module.exports = BandView
