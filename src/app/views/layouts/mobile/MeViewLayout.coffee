Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

width = Utils.getViewportWidth()
height = Utils.getViewportHeight()

module.exports =
  unicorn:
    size: [width, height - 50]
    origin: [0.5, 0.5]
    align: [0.5, 0.5]
    classes: ['me__unicorn']
    inTransition:  { duration: 500, curve: Easing.outCubic }
    outTransition: { duration: 350, curve: Easing.outCubic }
