Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  cards:
    align: [0, 0.04]
    origin: [0, 0]
    states: [
      # showing state
      {
        delay: 0
        align: [0, 0]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # comments showing state
      {
        delay: 0
        align: [0, -0.6]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # end state
      {
        delay: 0
        align: [-1, 0],
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # start state
      {
        delay: 0,
        align: [3, 0],
        # transition: {duration: 500, curve: Easing.outQuad}
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
  status:
    origin: [0.5, 0]
    align: [0.5, 1]
    size: [Utils.getViewportWidth(), ]
    states: [

      # start state 
      {
        delay: 0
        align: [2, 0]
        transition: {duration: 500, curve: Easing.inQuad}
      }

      # showing state
      {
        delay: 0
        align: [0.5, 0]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # end state
      {
        delay: 0
        align: [-1, 0]
        transition: {duration: 1000, curve: Easing.outQuad}
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

# Can't get physics to work.
#      # showing state
#      {
#        delay: 100
#        transform: Transform.translate Utils.getViewportWidth()/2, Utils.getViewportHeight()/2, 0
#        transition: { method: "spring", period: 1000, dampingRatio: 0.3 }
#      }
#      # hiding state
#      {
#        delay: 200
#        transform: Transform.translate Utils.getViewportWidth()/2, Utils.getViewportHeight(), 0
#        transition: {duration: 500, curve: Easing.outQuad}
#      }
    ]

