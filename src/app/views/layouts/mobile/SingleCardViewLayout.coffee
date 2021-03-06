Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
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
  points:
    origin: [0.5, 0.5]
    align: [0.5, 1.5]
#    transform: Transform.translate Utils.getViewportWidth()/2, Utils.getViewportHeight(), 0
    transform: Transform.scale 0, 0, 0
    size: [80, 80]
    classes: ['play__points']
    states: [
      {
        delay: 80
        transform: Transform.scale 1, 1, 1
        transition: {duration: 400, curve: Easing.outQuad}
      }
      {
        delay: 80
        align: [0.5, 0.5]
        transition: {duration: 400, curve: Easing.outQuad}
      }
      {
        delay: 100
        transform: Transform.scale 2, 2, 2
        transition: {duration: 400, curve: Easing.outQuad}
      }# showing state
      {
        delay: 120
        transform: Transform.scale 1, 1, 1
        transition: {duration: 400, curve: Easing.outQuad}
      }
      {
        delay: 150
        transform: Transform.scale 0, 0, 0
        transition: {duration: 200, curve: Easing.outQuad}
      }
      {
        delay: 150
        align: [0.5, 1.5]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
