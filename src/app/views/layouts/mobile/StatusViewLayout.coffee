Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  view:
    origin: [0.5, 0]
    align: [0.5, 1]
    size: [Utils.getViewportWidth(), Utils.getViewportHeight()]