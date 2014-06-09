require './scss/bandmenu'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ImageSurface = require 'famous/surfaces/ImageSurface'
MenuActions = require 'actions/MenuActions'


class BandMenuItemView extends View
  @DEFAULT_OPTIONS:
    pageID: null
    width: 250
    height: window.innerHeight / 4
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 50

  constructor: ->
    super
    @createBackground()
    @createIcon()

  createBackground: ->
    @background = new Surface
      size: [@options.width, @options.height]
      content: "<div class='bandmenu__item__title'>#{@options.title}</div>"
      classes: ['bandmenu__item', "bandmenu__item--#{@options.pageID}"]
    @add @background
    @background.on 'click', =>
      MenuActions.selectMenuItem @getID()

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
      classes: ['bandmenu__item__logo']
    @iconState = new StateModifier
        transform: Transform.translate 20, @options.height/2 - @options.iconSize/2, 0
    @add(@iconState).add @icon

  getID: ->
    @options.pageID

module.exports = BandMenuItemView
