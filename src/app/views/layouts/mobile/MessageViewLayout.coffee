Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  wrapper:
    origin: [0.5, 0.5]
    align: [0.5, 0.5]
    transform: Transform.translate null, null, 30
  text:
    transform: Transform.translate null, -10, null
    size: [Utils.getViewportWidth() - 100, 160]
  okButton:
    transform: Transform.translate null, 80, null
    size: [Utils.getViewportWidth() - 100, 60]
  overlay:
    size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
  box:
    size: [Utils.getViewportWidth() - 40, 280]

