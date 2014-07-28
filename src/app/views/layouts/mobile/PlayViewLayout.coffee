Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'

module.exports =
  cards:
    align: [0, 0.04]
    origin: [0, 0]
    states: [
      # showing state
      {
        delay: 0
        align: [0, 0.04]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # comments showing state
      {
        delay: 0
        align: [0, -0.6]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # end state
      {
        delay: 0
        align: [-1, 0.04],
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # start state
      {
        delay: 0,
        align: [3, 0.04],
        # transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  unicorn:
    size: [90, 100]
    classes: ['play__unicorn']
    align: [0.17, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -20000
    states: [
      {
        delay: 0
        align: [0.17, 0.4]
        transform: Transform.translate null, null, -20000
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 0
        align: [0.17, 0.13]
        opacity: 1
        transform: Transform.translate null, null, -3
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 40
        opacity: 0
        transition: {duration: 500, curve: Easing.inBounce}
      }
  ]
  bubble:
    size: [230, 90]
    classes: ['card__message__bubble']
    align: [0.6, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -20000
    states: [
      {
        delay: 10
        align: [0.6, 0.4]
        transform: Transform.translate null, null, -20000
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 15
        align: [0.6, 0.1]
        opacity: 1
        transform: Transform.translate null, null, -4
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 40
        opacity: 0
        transition: {duration: 500, curve: Easing.inBounce}
      }
    ]
  message:
    size: [220, 80]
    classes: ['card__message']
    align: [0.5, 0.4]
    origin: [0.5, 0.5]
    transform: Transform.translate null, null, -20000
    states: [
      {
        delay: 10
        align: [0.5, 0.4]
        transform: Transform.translate null, null, -20000
        transition: {duration: 500, curve: Easing.inQuad}
      }
      {
        delay: 15
        align: [0.62, 0.11]
        opacity: 1
        transform: Transform.translate null, null, -3
        transition: {duration: 500, curve: Easing.inBounce}
      }
      {
        delay: 40
        opacity: 0
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
        # align: [0.5, 0.25]
        transition: {duration: 500, curve: Easing.outQuad}
      }
      {
        delay: 0
        align: [0.5, 0.25]
        # align: [0.5, 0.35]
        transition: {duration: 500, curve: Easing.outQuad}
      }
    ]
  newComment:
    size: [window.innerWidth - 50, 40]
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
  status:
    origin: [0.5, 0]
    align: [0.5, 1]
    size: [window.innerWidth, window.innerHeight]
    states: [

      # start state 
      {
        delay: 0
        align: [2, 0.09]
        transition: {duration: 500, curve: Easing.inQuad}
      }

      # showing state
      {
        delay: 0
        align: [0.5, 0.09]
        transition: {duration: 500, curve: Easing.outQuad}
      }

      # end state
      {
        delay: 0
        align: [-1, 0.09]
        transition: {duration: 1000, curve: Easing.outQuad}
      }
    ]

