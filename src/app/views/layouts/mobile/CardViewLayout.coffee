Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

width = Utils.getViewportWidth()
height = Utils.getViewportHeight()

module.exports = {
  question:
    big:
      delay: 0
      size: [width - 50, 150]
      classes: ['card__front__question']
      transform: Transform.translate 0, 210, 3
      transition: {duration: 500, curve: Easing.outQuad}
    small:
      delay: 0
      size: [width - 120, 75]
      classes: ['card__front__question--small']
      transform: Transform.translate 30, 100, 2.5
#      origin: [0, 0]
#      align: [0.3, 0.18]
      transition: {duration: 500, curve: Easing.outQuad}
  profilePic:
    size: [100, 100]
    big:
      delay: 0
      transform:  Transform.multiply(
        Transform.scale 1, 1, 1
        Transform.translate 0, 100, 2.5
      )
#      align: [0.5, 0.3]
#      origin: [0.5, 0.5]
      transition: {duration: 500, curve: Easing.outQuad}
      classes: ['card__front__pic--big']
    small:
      delay: 0
      transform: Transform.multiply(
        Transform.scale .5, .5, 1
        Transform.translate -210, 200, 2.5
      )
#      align: [0.1, 0.18]
#      origin: [0, 0]
      transition: {duration: 500, curve: Easing.outQuad}
      classes: ['card__front__pic--small']
  card:
    origin: [0.5, 0]
    align: [0.5, 0]
    size: [width - 20, height - 180]
    transition: {duration: 500, curve: Easing.outQuad}
    front:
      transform: Transform.translate 0, 78, null
#      hide: Transform.translate 0,0, -1000
    back:
      transform: Transform.multiply(
        Transform.translate(0, 78, 2.5)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
  answerImage:
    size: [width - 60, null]
    borderRadius: 10
    maxHeight: width - width * .1 - 100
#    maxWidth: width - 60
    classes: ['card__back__image']
    transform:  Transform.multiply(
      Transform.translate(0, 200, .5)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  answerText:
    size: [width - 60, 100]
    classes: ['card__back__text']
    transform: Transform.multiply(
      Transform.translate(0, 105, .5)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  addImage:
    size: [43, 48]
    classes: ['card__back__addImage']
    content: 'images/add-image.png'
    origin: [0.5, 1]
    align: [0, 1]
    transform: Transform.multiply(
      Transform.translate 0, -80, -4
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  choices:
    size: [width - width * .1, height - 300]
    align: [0.5, 0.5]
    origin: [0.5, 0.5]
    transform: Transform.translate 0, 180, 4
    choice:
      size: [width - width * .1, 65]
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      innerWidth: width - width * .2
      height: 60
  answerPic:
    borderRadius: 10
    size: [width - width * .1, height - height * .25]
}
