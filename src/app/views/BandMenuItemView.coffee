require './scss/bandmenu'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
NavActions = require 'actions/NavActions'
Utils = require 'lib/Utils'


class BandMenuItemView extends View
  @DEFAULT_OPTIONS:
    pageID: null
    width: Utils.getViewportWidth() - 60
    height: Utils.getViewportHeight() / 4
    angle: -0.2
    iconUrl: 'images/mark_tiny.png'
    title: 'pegg'
    color: 'white'
    iconSize: 60

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
      NavActions.selectMenuItem @getID()

  createIcon: ->
    @icon = new ImageSurface
      size: [@options.iconSize, @options.iconSize]
      content: @options.iconUrl
      classes: ['bandmenu__item__logo']
    @iconState = new StateModifier
        transform: Transform.translate 20, @options.height/2 - @options.iconSize/2, 0
    @icon.on 'click', =>
      NavActions.selectMenuItem @getID()
    @add(@iconState).add @icon

  getID: ->
    @options.pageID

module.exports = BandMenuItemView
