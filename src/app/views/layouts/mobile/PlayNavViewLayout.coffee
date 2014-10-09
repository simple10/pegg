Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  wrapper:
    size: [Utils.getViewportWidth(), 80]
    origin: [0.5, 0]
    align: [0.5, 0.07]
    transform: Transform.translate null, null, -5
    states: [
      # showing state
      {
        delay: 0
        align: [0.5, 0.07]
        transition: {duration: 500, curve: Easing.outQuad}
      }
      # hidden state
      {
        delay: 0
        align: [0.5, -1]
        transition: {duration: 500, curve: Easing.inQuad}
      }
    ]
  leftArrow:
    origin: [0.5, 0.5]
    align: [0.1, 0.08]
    size: [36, 36]
    states: [
      # show
      {
        delay: 0
        transform: Transform.translate null, 0, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
      # hide
      {
        delay: 0
        transform: Transform.translate null, -200, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
    ]
  moodImage:
    origin: [0.5, 0.5]
    align: [0.15, 0.03]
    size: [50, 50]
    states: [
      # show
      {
        delay: 0
        transform: Transform.translate null, 0, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
      # hide
      {
        delay: 0
        transform: Transform.translate null, -200, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
    ]
  title:
    size: [180, 50]
    classes: ['card__title']
    align: [0.5, 0.05]
    origin: [0.5, 0.5]
    states: [
      {
        delay: 0
        align: [0.5, 0.05]
        transform: Transform.translate null, null, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 15
        align: [0.5, -0.5]
        transition: {duration: 500, curve: Easing.inExpo}
      }
    ]
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
    states: [
      # show
      {
        delay: 0
        transform: Transform.translate null, 0, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
      # hide
      {
        delay: 0
        transform: Transform.translate null, -200, null
        transition: {duration: 500, curve: Easing.inQuad}
      }
    ]
  backArrow:
      origin: [0.5, 0.5]
      align: [0.1, 0.08]
      size: [46, 31]
      states: [
        # show
        {
          delay: 0
          transform: Transform.translate null, 0, null
          transition: {duration: 500, curve: Easing.inQuad}
        }
        # hide
        {
          delay: 0
          transform: Transform.translate null, -200, null
          transition: {duration: 500, curve: Easing.inQuad}
        }
      ]
