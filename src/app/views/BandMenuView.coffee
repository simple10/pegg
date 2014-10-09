require './scss/bandmenu.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
BandMenuItemView = require 'views/BandMenuItemView'
_ = require('Parse')._
Utils = require 'lib/Utils'

###
# Events:
###
class BandMenuView extends View
  @DEFAULT_OPTIONS:
    angle: -0.2
    width: null
    topOffset: 0
    band:
      offset: Utils.getViewportHeight() / 4
      staggerDelay: 35
      transition:
        duration: 400
        curve: 'easeOut'
    model: null

  constructor: (options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @initBackground()
    @initBands()

  initBackground: ->
    @background = new Surface
      size: [@options.width, undefined]
      classes: ["bandmenu__background"]
    @backgroundState = new StateModifier
      transform: Transform.translate -@options.width, 0, 0
    @add(@backgroundState).add @background

  initBands: ->
    @bandModifiers = []
    yOffset = @options.topOffset
    bands = @options.model
    i = 0
    while i < bands.length
      band = new BandMenuItemView bands[i]
      bandModifier = new StateModifier
        transform: Transform.translate 0, yOffset, 0
      @bandModifiers.push bandModifier
      @add(bandModifier).add band
      yOffset += @options.band.offset
      i++


  resetBands: ->
    i = 0
    while i < @bandModifiers.length
      initX = -@options.width
      initY = @options.topOffset + @options.band.offset * i + @options.width * Math.tan(-@options.angle)
      @bandModifiers[i].setTransform Transform.translate(initX, initY, 0)
      i++

  show: ->
    @showBackground()
    @showBands()

  hide: ->
    @hideBackground()
    @hideBands()

  hideBackground: ->
    @backgroundState.setTransform Transform.translate(-@options.width, 0, 0), @options.band.transition

  showBackground: ->
    @backgroundState.setTransform Transform.translate(0, 0, 0), @options.band.transition

  showBands: ->
    @resetBands()
    transition = @options.band.transition
    delay = @options.band.staggerDelay
    bandOffset = @options.band.offset
    topOffset = @options.topOffset
    i = 0
    while i < @bandModifiers.length
      Timer.setTimeout ((i) ->
        yOffset = topOffset + bandOffset * i
        @bandModifiers[i].setTransform Transform.translate(0, yOffset, 0), transition
        return
      ).bind(this, i), i * delay
      i++


  hideBands: ->
    transition = @options.band.transition
    delay = @options.band.staggerDelay
    i = 0
    while i < @bandModifiers.length
      Timer.setTimeout ((i) ->
        initX = -@options.width
        initY = @options.topOffset + @options.band.offset * i + @options.width * Math.tan(-@options.angle)
        @bandModifiers[i].setTransform Transform.translate(initX, initY, 0), transition
        return
      ).bind(this, i), i * delay
      i++



module.exports = BandMenuView
