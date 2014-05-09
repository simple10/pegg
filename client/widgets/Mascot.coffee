View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'


class Mascot extends View
  constructor: ->
    super

    @stateModifier = new StateModifier

    @modifier = @add(@stateModifier)

    @modifier.add new ImageSurface
      size: [417, 800]
      content: '/images/mascot_medium.png'

    @stateModifier.setTransform(
      Transform.translate 0, 300
      duration : 1000
      curve: Easing.inExpo
    )

    @stateModifier.setTransform(
      Transform.translate 100, 300
      {
        duration : 800
        curve: Easing.outElastic
      }
      =>
        # Talk bubble
        @modifier.add new Modifier
          transform: Transform.translate 400, 0
        .add new ImageSurface
          size: [192, 200]
          content: 'images/talk_medium.png'
        @modifier.add new Modifier
          transform: Transform.translate 480, 60
        .add new Surface
          classes: ['talk']
          content: 'Sup?'
        Timer.setTimeout =>
          @fadeOut()
        , 1000

    )

  fadeOut: ->
    @stateModifier.setOpacity(
      0
      duration: 500
      curve: Easing.outCubic
    )

module.exports = Mascot

