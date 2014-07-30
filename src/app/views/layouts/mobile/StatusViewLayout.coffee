Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'

module.exports =
  view:
    origin: [0.5, 0]
    align: [0.5, 1]
    size: [window.innerWidth, window.innerHeight]
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