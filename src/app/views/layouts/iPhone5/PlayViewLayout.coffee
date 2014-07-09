Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'

module.exports =
  cards:
    align: [0, 0.04]
    origin: [0, 0]
    states: [
      {
        delay: 0
        align: [0, 0.04]
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 0
        align: [0, -0.6]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  unicorn:
    size: [80, 160]
    classes: ['play__unicorn']
    align: [0.17, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -10000
    states: [
      {
        delay: 0
        align: [0.17, 0.4]
        transform: Transform.translate null, null, -10000
        transition: {duration: 1000, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.17, 0.18]
        transform: Transform.translate null, null, -3
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  bubble:
    size: [250, 100]
    classes: ['card__message__bubble']
    align: [0.6, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -10000
    states: [
      {
        delay: 20
        align: [0.6, 0.4]
        transform: Transform.translate null, null, -10000
        transition: {duration: 1000, curve: Easing.inQuad}
      }
      {
        delay: 20
        align: [0.6, 0.12]
        transform: Transform.translate null, null, -4
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  message:
    size: [300, 200]
    classes: ['card__message']
    align: [0.5, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -10000
    states: [
      {
        delay: 20
        align: [0.5, 0.4]
        transform: Transform.translate null, null, -10000
        transition: {duration: 1000, curve: Easing.inQuad}
      }
      {
        delay: 20
        align: [0.6, 0.26]
        transform: Transform.translate null, null, -3
        transition: {duration: 500, curve: Easing.inBounce}
      }
    ]
  comments:
    origin: [0.5, 0]
    align: [0.5, 1]
    states: [
      {
        delay: 0
        align: [0.5, 1]
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.5, 0.9]
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 0
        align: [0.5, 0.3]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  newComment:
    origin: [0.5, 0]
    align: [0.5, 1]
    states: [
      {
        delay: 0
        align: [0.5, 1]
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.5, 0.9]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
