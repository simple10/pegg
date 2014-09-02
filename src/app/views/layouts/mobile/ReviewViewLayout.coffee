Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  card:
    align: [0.5, 0]
    origin: [0.5, 0]
    states: [
      # showing state
      {
        delay: 0
        align: [0.5, 0.5]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # comments showing state
      {
        delay: 0
        align: [0.5, -0.6]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  comments:
    origin: [0.5, 0]
    align: [0.5, 1]
    states: [
      {
        delay: 0
        align: [0.5, 1]
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.5, 0.92]
        # align: [0.5, 0.25]
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 0
        align: [0.5, 0.35]
        # align: [0.5, 0.35]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  newComment:
    size: [Utils.getViewportWidth() - 50, 40]
    origin: [0.5, 0]
    align: [0.5, 1]
    states: [
      {
        delay: 0
        align: [0.5, 1]
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.5, 0.9]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
