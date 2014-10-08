Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  wrapper:
    origin: [0.5, 0.5]
    align: [0.5, 0.5]
  text:
    transform: Transform.translate null, -80, 1
    size: [Utils.getViewportWidth() - 60, 200]
  okButton:
    transform: Transform.translate null, 80, 1
    size: [Utils.getViewportWidth() - 100, 40]
  overlay:
    size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
  box:
    size: [Utils.getViewportWidth() - 20, 333]

