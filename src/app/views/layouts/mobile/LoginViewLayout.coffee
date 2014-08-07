Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  logo:
    size: [320, 220]
    classes: ['login__logo']
    align: [0.5, 0]
    origin: [0.5, 1]
    states: [
      {
        delay: 10
#        scale: [0, 0, 0]
        transition: {duration: 500, curve: Easing.inBounce}
      }
      {
        delay: 50
        align: [0.5, 0.4]
#        scale: [1, 1, 0]
        transition: {duration: 500, curve: Easing.inOutBack}
      }
    ]
  mark:
    size: [130, null]
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
        align: [0.5, 0.4]
        origin: [0.5, 0]
        transition: {duration: 500, curve: Easing.outBounce}
      }
    ]
  text:
    size: [130, null]
    classes: ['login__text--header']
    align: [0.5, 0]
    origin: [0.5, 1]
    states: [
      {
        delay: 35
        align: [0.5, 0.5]
        origin: [0.5, 0.5]
        transition: {duration: 500, curve: Easing.inOutBack}
      }
      {
        delay: 50
        align: [0.5, 0.4]
        origin: [0.5, 0]
        transition: {duration: 500, curve: Easing.outBounce}
      }
    ]
  fbButton:
    size: [Utils.getViewportWidth(), Utils.getViewportHeight() / 4]
    classes: ['login__button--facebook']
    align: [1, 0.45]
    origin: [0, 0]
    states: [
      {
        delay: 60
        align: [0, 0.5]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]
  gpButton:
    size: [Utils.getViewportWidth(), Utils.getViewportHeight() / 4]
    classes: ['login__button--google']
    align: [1, 0.7]
    origin: [0, 0]
    states: [
      {
        delay: 80
        align: [0, 0.75]
        transform: Transform.translate null, null, 1
        transition: {duration: 600, curve: Easing.inOutBack}
      }
    ]
