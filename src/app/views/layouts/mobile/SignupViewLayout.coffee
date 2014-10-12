Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'

module.exports =
  logo:
    size: [undefined, 250]
    classes: ['login__logo']
    align: [0.5, 0]
    origin: [0.5, 1]
    states: [
      {
        delay: 0
#        scale: [0,0,0]
      }
      {
        delay: 30
        align: [0.5, 0]
        origin: [0.5, 0]
#        scale: [1,1,0]
        transition: {duration: 800, curve: Easing.outExpo}
      }
    ]

  mark:
    size: [150, 70]
    classes: ['login__mark']
    align: [0.5, 0.5]
    origin: [0.5, 0.5]
#    states: [
#      {
#        delay: 35
##        scale: [1.3,1.3,0]
#        transition: {duration: 300, curve: Easing.outExpo}
#      }
#      {
#        delay: 55
##        scale: [1,1,0]
#        transition: {duration: 300, curve: Easing.outExpo}
#      }
#    ]

  signupText:
    size: [300, 50]
    classes: ['signup__text--header']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 100
        align: [0.5, .9]
        origin: [0.5, 0]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]

  signupInput:
    size: [300, 50]
    classes: ['signup__email__input']
    align: [1, 0.8]
    origin: [0, 0.5]
    states: [
      {
        delay: 40
        align: [0.5, 0.75]
        origin: [0.5, 0.5]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]

  signupButton:
    size: [300, 50]
    classes: ['signup__submit']
    align: [1, 0.9]
    origin: [0, 0.5]
    states: [
      {
        delay: 60
        align: [0.5, 0.85]
        origin: [0.5, 0.5]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]

  signupMessage:
    size: [300, 50]
    classes: ['signup__response']
    origin: [0.5, 0.5]
    align: [0.5, -0.07]
    states: [
      {
        align: [0.5, 0.95]
        origin: [0.5, 0.5]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]
