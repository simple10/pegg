Easing = require 'famous/transitions/Easing'

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
        align: [0.45, 0]
        scale: [0.4, 0.4, 0]
        transition: {duration: 500, curve: Easing.outBounce}
      }
    ]

  mark:
    size: [150, 70]
    classes: ['login__mark']
    align: [0.5, 1]
    origin: [0.5, 1]
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

  signupText:
    size: [300, 50]
    classes: ['signup__text--header']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 100
        align: [0.5, .7]
        origin: [0.5, 0.5]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]

  signupInput:
    size: [300, 50]
    classes: ['signup__email__input']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 120
        align: [0.5, 0.8]
        origin: [0.5, 0.5]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]

  signupButton:
    size: [300, 50]
    classes: ['signup__submit']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 120
        align: [0.5, 0.9]
        origin: [0.5, 0.5]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]

  signupMessage:
    size: [300, 50]
    classes: ['signup__response']
    origin: [0.5, 0.5]
    align: [0.5, -0.07]
    states: [
      {
        align: [0.5, 1]
        origin: [0.5, 0.5]
        transition: {duration: 1000, curve: Easing.outBounce}
      }
    ]
