View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ImageSurface = require 'famous/surfaces/ImageSurface'


class BandView extends View
  @DEFAULT_OPTIONS:
    menuID: null
    width: 280
    height: 100
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 50

  constructor: ->
    super
    @createBackground()
    @createIcon()
    #@createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      content: "<div class='menu__item__title'>#{@options.title}</div>"
      #content: @options.menuID
      #properties:
      #  lineHeight: @options.height + 'px'
      #  textAlign: 'center'
      classes: ['menu__item', "menu__item--#{@options.menuID}"]
    @add @background
    @background.on 'click', =>
      @_eventOutput.emit 'selectMenuItem', @

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
    @iconState = new StateModifier
        transform: Transform.translate 20, @options.height/2 - @options.iconSize/2, 0
    @add(@iconState).add @icon
    #@add @icon

  #createTitle: ->
  #  @title = new Surface
  #    size: [@options.width, @options.height]
  #    content: @options.title
  #    classes: ['menu__item__title']
  #  @titleState = new StateModifier
  #    transform: Transform.translate @options.width/2, @options.height/2, 0
  #  @add(@titleState).add @title
    #@add @title

  getID: ->
    @options.menuID

module.exports = BandView
