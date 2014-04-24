View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier  = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'


class Mascot extends View
  constructor: ->
    super

    @image = new ImageSurface
      size: [417, 800]
      content: 'images/mascot_medium.png'

    stateModifier = new StateModifier

    @add(stateModifier).add @image

    stateModifier.setTransform(
      Transform.translate 0, 300
      duration : 1000
      curve: Easing.inExpo
    )

    stateModifier.setTransform(
      Transform.translate 100, 300
      duration : 800
      curve: Easing.outElastic
      =>
        # Talk bubble
        @add new Modifier
          transform: Transform.translate 450, 250
        .add new ImageSurface
          size: [192, 200]
          content: 'images/talk_medium.png'
        @add new Modifier
          transform: Transform.translate 530, 320
        .add new Surface
          classes: ['talk']
          content: 'Sup?'
    )


module.exports = Mascot

