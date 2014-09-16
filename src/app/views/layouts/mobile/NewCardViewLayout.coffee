Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

module.exports =
  cardIcon:
    size: [83, 58]
    classes: ['newcard_card_icon']
    align: [0.5, 0.15]
    origin: [0.35, 0.5]
  newCardTitle:
    size: [Utils.getViewportWidth() - 50, 50]
    classes: ['newcard__header']
    align: [0.5, 0.28]
    origin: [0.5, 0.5]
  categories:
    size: [window.innerWidth, window.innerHeight]
    classes: ['newcard__categories']
    align: [0, 1]
    origin: [0, 0]
    states: [
      {
        delay: 10
        align: [0, 0]
        transform: Transform.translate null, null, 10
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 20
        align: [0, 1]
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  category:
    size: [window.innerWidth, 100]
    classes: ['newcard__category']
  categoriesConfirm:
    size: [undefined, 50]
  step1_0: # number
    size: [30, 30]
    classes: ['newcard__number']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.3]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 20
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step1_1: # input field
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.4]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 10
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step1_2: # button
    size: [Utils.getViewportWidth() - 50, 40]
    classes: ['newcard__button']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.5]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step2_0: # number
      size: [30, 30]
      classes: ['newcard__number']
      align: [0.5, 1]
      origin: [0.5, 0]
      states: [
        {
          delay: 10
          align: [0.5, 0.3]
          transform: Transform.rotateZ(0)
          transition: {duration: 1000, curve: Easing.outCubic}
        }
        {
          delay: 50
          align: [0.5, 1.5]
          transform: Transform.rotateZ(1)
          transition: {duration: 500, curve: Easing.inCubic}
        }
      ]
  step2_1: # input field
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 0
        align: [0.5, 0.4]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 40
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step2_2: # input field
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.5]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 30
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step2_3: # input field
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 20
        align: [0.5, 0.6]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 20
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step2_4: # input field
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 30
        align: [0.5, 0.7]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 10
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step2_5: # button
    size: [Utils.getViewportWidth() - 50, 40]
    classes: ['newcard__button']
    align: [0.5, 1]
    origin: [0.5, -0.5]
    states: [
      {
        delay: 10
        align: [0.5, 0.8]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step3_0: # number
    size: [30, 30]
    classes: ['newcard__number']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.3]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 30
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
  ]
  step3_1: # link container
    size: [ [Utils.getViewportWidth()-30, 55], [59, 55], [Utils.getViewportWidth() - 100, 55] ]
    align: [0.5, 1]
    origin: [0.5, 0]
    classes: {image: ['newcard__step3__deckIcon'], text: ['newcard__step3__deckText']}
    states: [
      {
        delay: 0
        align: [0.5, 0.45]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 20
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step3_2: # surface
    size: [Utils.getViewportWidth() - 50, 40]
    align: [0.5, 1]
    origin: [0.5, 0]
    classes: ['newcard__step3__deckText', 'newcard__center']
    states: [
      {
        delay: 10
        align: [0.5, 0.57]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 10
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  # step3_3: # link container
  #   size: [ [Utils.getViewportWidth()-30, 55], [70, 55], [Utils.getViewportWidth() - 90, 55] ]
  #   align: [0.5, 1]
  #   origin: [0.5, 0]
  #   classes: {image: ['newcard__step3__deckIcon'], text: ['newcard__step3__deckText']}
  #   states: [
  #     {
  #       delay: 10
  #       align: [0.5, 0.9]
  #       transform: Transform.rotateZ(0)
  #       transition: {duration: 1000, curve: Easing.outCubic}
  #     }
  #     {
  #       delay: 10
  #       align: [0.5, 1.5]
  #       transform: Transform.rotateZ(1)
  #       transition: {duration: 500, curve: Easing.inCubic}
  #     }
  #   ]
  step3_3: # button
    size: [Utils.getViewportWidth() - 50, 40]
    classes: ['newcard__button']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.9]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step4_0: # surface
    size: [Utils.getViewportWidth() - 100, 40]
    classes: ['newcard__header--big']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.3]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step4_1: # button
    size: [Utils.getViewportWidth() - 50, 40]
    classes: ['newcard__button', 'newcard__button--blue']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 10
        align: [0.5, 0.45]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
  step4_2: # button
    size: [Utils.getViewportWidth() - 50, 40]
    classes: ['newcard__button', 'newcard__button--blue']
    align: [0.5, 1]
    origin: [0.5, 0]
    states: [
      {
        delay: 20
        align: [0.5, 0.55]
        transform: Transform.rotateZ(0)
        transition: {duration: 1000, curve: Easing.outCubic}
      }
      {
        delay: 0
        align: [0.5, 1.5]
        transform: Transform.rotateZ(1)
        transition: {duration: 500, curve: Easing.inCubic}
      }
    ]
