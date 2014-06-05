require './tabmenu'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ImageSurface = require 'famous/surfaces/ImageSurface'
MenuActions = require 'actions/MenuActions'

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
    #@createIcon()
    #@createTitle()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      #size: [null, null]
      classes: ['tabmenu__item', "tabmenu__item--#{@options.pageID}"]
    @add @background
    @background.on 'click', =>
      MenuActions.selectMenuItem @getID()

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
    @iconState = new StateModifier
      #origin: [0.5, 0.5]
      #align: [0.5, 0.5]
        #transform: Transform.translate 20, @options.iconSize/2, 0
    @add(@iconState).add @icon

  createTitle: ->
    @title = new Surface
      size: [@options.width, @options.height]
      content: @options.title
      classes: ['tabmenu__item__title']
    @titleState = new StateModifier
      transform: Transform.translate @options.width/2, @options.height/2, 0
    @add(@titleState).add @title

  getID: ->
    @options.pageID

module.exports = TabMenuItemView
