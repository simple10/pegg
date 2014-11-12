Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  height: 55
  width: Utils.getViewportWidth() - 60
  staggerDelay: 35
  transition:
    duration: 300
    curve: 'easeOut'

