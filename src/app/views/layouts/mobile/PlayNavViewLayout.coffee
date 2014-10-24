Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =

  show:
    delay: 0
    transform: Transform.translate null, 0, null
    transition: {duration: 500, curve: Easing.inQuad}

  hide:
    delay: 0
    transform: Transform.translate null, -200, null
    transition: {duration: 500, curve: Easing.inQuad}

  wrapper:
    size: [Utils.getViewportWidth(), 80]
    origin: [0.5, 0]
    align: [0.5, 0.07]
    transform: Transform.translate null, null, -5

  leftArrow:
    origin: [0.5, 0.5]
    align: [0.1, 0.08]
    size: [36, 36]

  moodImage:
    origin: [0.5, 0.5]
    align: [0.15, 0.03]
    size: [50, 50]

  title:
    size: [180, 50]
    classes: ['card__title']
    align: [0.5, 0.05]
    origin: [0.5, 0.5]

  progress:
    size: [160, 55]
    origin: [0.5, 0.5]
    align: [0.5, 0.29]
    bar:
      align: [0.5, 0.1]
      origin: [0.5, 0]
      size: [160, 15]
      active:
        classes: ['progressBar__active']
    percentage:
      align: [0.5, 0]
      origin: [0.5, 0]
      size: [25, 15]
      classes: ['progressBar__percentage']

  rightArrow:
    origin: [0.5, 0.5]
    align: [0.9, 0.08]
    size: [36, 36]

  backArrow:
    origin: [0.5, 0.5]
    align: [0.1, 0.08]
    size: [46, 31]
