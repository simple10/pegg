Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'

module.exports =
  logo:
    size: [417, 800]
    classes: ['login__logo']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.45, 0.5]
        transition: {duration: 1000, curve: Easing.inBounce}
      }
      {
        delay: 100
        align: [0.45, 0.1]
        scale: [0.5, 0.5, 0]
        transition: {duration: 500, curve: Easing.outExpo}
      }
    ]
  mark:
    size: [150, 70]
    classes: ['login__mark']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 35
        align: [0.5, 0.5]
        origin: [0.5, 0.5]
        transition: {duration: 500, curve: Easing.inOutBack}
      }
      {
        delay: 100
        align: [0.5, 0.6]
        origin: [0.5, 0]
        transition: {duration: 500, curve: Easing.outBounce}
      }
    ]
  fbButton:
    size: [window.innerWidth, window.innerHeight / 4]
    classes: ['login__button--facebook']
    align: [1, 0.45]
    origin: [0, 0]
    states: [
      {
        delay: 100
        align: [0, 0.5]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]
  gpButton:
    size: [window.innerWidth, window.innerHeight / 4]
    classes: ['login__button--google']
    align: [1, 0.7]
    origin: [0, 0]
    states: [
      {
        delay: 120
        align: [0, 0.75]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]
