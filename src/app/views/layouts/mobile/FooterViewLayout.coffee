Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  height: 60
  width: Utils.getViewportWidth() - 60
  staggerDelay: 35
  transition:
    duration: 300
    curve: 'easeOut'

