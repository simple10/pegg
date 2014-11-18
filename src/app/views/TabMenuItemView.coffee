require './scss/tabmenu'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
NavActions = require 'actions/NavActions'
Modifier = require 'famous/src/core/Modifier'

class TabMenuItemView extends View
  @DEFAULT_OPTIONS:
    pageID: null
    width: null
    height: null
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 40

  constructor: ->
    super
    @createBackground()
    @createIcon()
    @createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      #size: [null, null]
      classes: ['tabmenu__item']
#      , "tabmenu__item--#{@options.pageID}"
    @backgroundMod = new Modifier
      transform: Transform.translate 0, 0, null
      opacity: .3
    @add(@backgroundMod).add @background
    @background.on 'click', =>
      @menuSelect()


  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
      properties: @options.properties
    @iconState = new Modifier
#      origin: [0.5, 0.5]
#      align: [0.5, 0.5]
      transform: Transform.translate 10, 10, 1
    @add(@iconState).add @icon
    @icon.on 'click', =>
      @menuSelect()
#    @iconState.setTransform Transform.translate null, @options.height / 5, 10

  createTitle: ->
    @title = new Surface
      size: [@options.width-20, @options.height-20]
      content: @options.title
      classes: ['tabmenu__item__title']
    @titleState = new Modifier
      transform: Transform.translate 20, 20, 1
    @add(@titleState).add @title
    @title.on 'click', =>
      @menuSelect()

  getID: ->
    @options.pageID

  menuSelect: ->
    NavActions.selectMenuItem @getID()
    @background.setClasses ['tabmenu__item']
#    , "tabmenu__item--#{@options.pageID}"
#    @backgroundMod.setOpacity .3

module.exports = TabMenuItemView
