Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  progress:
    size: [Utils.getViewportWidth(), 10]
    origin: [0.5, 0]
    align: [0.5, 0]
    transform: Transform.translate null, null, 0
    active:
      classes: ['progressBar__active']
      transform: Transform.translate null, null, 1
    inTransition:  { duration: 500, curve: Easing.outCubic }
    outTransition: { duration: 350, curve: Easing.outCubic }

  cards:
    align: [0.5, 0]
    origin: [0, 0]
    states: [
      # showing state
      {
        delay: 0
        align: [0.5, 0.5]
        transition: {duration: 250, curve: Easing.outQuad}
      }

      # comments showing state
      {
        delay: 0
        align: [0.5, -0.6]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # new card state
      {
        delay: 0
        align: [0.5, 0.6]
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
    align: [0.5, 0.35]
    inTransition:  { duration: 500, curve: Easing.outCubic }
    outTransition: { duration: 350, curve: Easing.outCubic }
#    states: [
#      {
#        delay: 0
#        align: [0.5, 1]
#        transition: {duration: 500, curve: Easing.inQuad}
#      }
#      {
#        delay: 0
#        align: [0.5, 0.92]
#        # align: [0.5, 0.25]
#        transition: {duration: 500, curve: Easing.outQuad}
#      }
#      {
#        delay: 0
#        align: [0.5, 0.35]
#        # align: [0.5, 0.35]
#        transition: {duration: 500, curve: Easing.outQuad}
#      }
#    ]
  numComments:
    size: [Utils.getViewportWidth() - 50, 40]
    origin: [0.5, 0]
    align: [0.5, 0.94]
    inTransition: {duration: 500, curve: Easing.inQuad}
    outTransition: false
  newComment:
    size: [Utils.getViewportWidth() - 50, 40]
    transform: Transform.translate 0, -20, 0
  newCard:
    size: [Utils.getViewportWidth() - 100, Utils.getViewportWidth() - 100]
    classes: ['play__newCard']
    content: 'images/newcard-button.svg'
    origin: [0.5, 0.5]
    align: [0.5, 0.35]
    inTransition: { duration: 500, curve: Easing.outCubic }
    outTransition: { duration: 350, curve: Easing.outCubic }
    transform: Transform.translate null, null, -10
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

