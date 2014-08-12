Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  wrapper:
    size: [Utils.getViewportWidth(), 80]
    origin: [0.5, 0]
    align: [0.5, 0.07]
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
  message:
    size: [220, 80]
    classes: ['card__message']
    align: [0.5, -1]
    origin: [0.5, 0.5]
    states: [
      {
        delay: 0
        align: [0.5, 0.3]
        transform: Transform.translate null, null, 0
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 15
        align: [0.5, -0.5]
        transition: {duration: 500, curve: Easing.inExpo}
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
