require 'css/menu'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
BandView = require 'views/BandView'

###
# Events:
#   selectMenuItem {{menuID}}
#   toggleMenu
###
class MenuView extends View
  @DEFAULT_OPTIONS:
    angle: -0.2
    bandWidth: 280
    topOffset: 0
    bandOffset: 105
    staggerDelay: 35
    transition:
      duration: 400
      curve: 'easeOut'

  constructor: ->
    super
    @initBackground()
    @initBands()

  initBackground: ->
    @background = new Surface
      size: [@options.bandWidth, undefined]
      classes: ["menu__background"]
    #@add @background
    @background.on 'click', =>
      @_eventOutput.emit 'toggleMenu'

  initBands: ->
    @bandModifiers = []
    yOffset = @options.topOffset
    bands = [
      {menuID: 'peggboard', title: 'peggboard', iconUrl: 'images/mark_tiny.png'}
      {menuID: 'card', title: 'new card', iconUrl: 'images/mark_tiny.png'}
      {menuID: 'decks', title: 'decks', iconUrl: 'images/mark_tiny.png'}
      {menuID: 'settings', title: 'settings', iconUrl: 'images/mark_tiny.png'}
    ]
    i = 0
    while i < bands.length
      band = new BandView bands[i]
      band.on 'selectMenuItem', (menuItem) =>
        @_eventOutput.emit 'selectMenuItem', menuItem.getID()
      bandModifier = new StateModifier
        transform: Transform.translate 0, yOffset, 0
      @bandModifiers.push bandModifier
      @add(bandModifier).add band
      yOffset += @options.bandOffset
      i++

  resetBands: ->
    i = 0
    while i < @bandModifiers.length
      initX = -@options.bandWidth
      initY = @options.topOffset + @options.bandOffset * i + @options.bandWidth * Math.tan(-@options.angle)
      @bandModifiers[i].setTransform Transform.translate(initX, initY, 0)
      i++

  showBands: ->
    @resetBands()
    transition = @options.transition
    delay = @options.staggerDelay
    bandOffset = @options.bandOffset
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
    transition = @options.transition
    delay = @options.staggerDelay
    i = 0
    while i < @bandModifiers.length
      Timer.setTimeout ((i) ->
        initX = -@options.bandWidth
        initY = @options.topOffset + @options.bandOffset * i + @options.bandWidth * Math.tan(-@options.angle)
        @bandModifiers[i].setTransform Transform.translate(initX, initY, 0), transition
        return
      ).bind(this, i), i * delay
      i++


module.exports = MenuView
