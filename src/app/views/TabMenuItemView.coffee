require './scss/tabmenu'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
NavActions = require 'actions/NavActions'

class TabMenuItemView extends View
  @DEFAULT_OPTIONS:
    pageID: null
    width: null
    height: null
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 50

  constructor: ->
    super
    @createBackground()
#    @createIcon()
#    @createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      #size: [null, null]
      classes: ['tabmenu__item', "tabmenu__item--#{@options.pageID}"]
    @backgroundMod = new StateModifier
#      opacity: .3
    @add(@backgroundMod).add @background
    @background.on 'click', =>
      @menuSelect()


  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
      properties: @options.properties
    @iconState = new StateModifier
      #origin: [0.5, 0.5]
      #align: [0.5, 0.5]
      transform: Transform.translate 17, 10, null
    @add(@iconState).add @icon
    @icon.on 'click', =>
      @menuSelect()

  createTitle: ->
    @title = new Surface
      size: [@options.width, @options.height]
      content: @options.title
      classes: ['tabmenu__item__title']
    @titleState = new StateModifier
      transform: Transform.translate 0, @options.height/2, null
    @add(@titleState).add @title

  getID: ->
    @options.pageID

  menuSelect: ->
    NavActions.selectMenuItem @getID()
    @background.setClasses ['tabmenu__item', "tabmenu__item--#{@options.pageID}"]
    @backgroundMod.setOpacity 1

module.exports = TabMenuItemView
