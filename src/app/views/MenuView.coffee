View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
BandView = require 'views/BandView'


class MenuView extends View
  @DEFAULT_OPTIONS:
    angle: -0.2
    bandWidth: 400
    #bandHeight: 100
    topOffset: 0
    bandOffset: 105
    staggerDelay: 35
    transition: {
      duration: 400
      curve: 'easeOut'
    }

  constructor: ->
    super
    @addBands()

  addBands: ->
    @bandModifiers = []
    yOffset = @options.topOffset

    i = 0
    bands = [
      {title: 'peggboard', iconUrl: 'images/mark_tiny.png', color: 'orange'},
      {title: 'new card', iconUrl: 'images/mark_tiny.png', color: 'yellow'},
      {title: 'decks', iconUrl: 'images/mark_tiny.png', color: 'green'},
      {title: 'settings', iconUrl: 'images/mark_tiny.png', color: 'blue'}
    ]

    while i < bands.length
      band = new BandView
        iconUrl: bands[i].iconUrl
        title: bands[i].title
        color: bands[i].color
      bandModifier = new StateModifier
        transform: Transform.translate(0, yOffset, 0)
      @bandModifiers.push bandModifier
      @add(bandModifier).add(band);

      yOffset += @options.bandOffset;
      i++

  MenuView::resetBands = ->
    i = 0

    while i < @bandModifiers.length
      initX = -@options.bandWidth
      initY = @options.topOffset + @options.bandOffset * i + @options.bandWidth * Math.tan(-@options.angle)
      @bandModifiers[i].setTransform Transform.translate(initX, initY, 0)
      i++
    return

  MenuView::animateBands = ->
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
    return



module.exports = MenuView
