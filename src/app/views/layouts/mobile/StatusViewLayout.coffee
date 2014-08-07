Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  view:
    origin: [0.5, 0]
    align: [0.5, 1]
    size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
    states: [
      # show
      {
        delay: 0
        align: [0.5, 0.5]
        origin: [0.5, 0.5]
      }
      # hide
      {
        delay: 0
        align: [0.5, 0]
        origin: [0.5, 1]
      }
    ]