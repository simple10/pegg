Easing = require 'famous/transitions/Easing'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

width = Utils.getViewportWidth()
height = Utils.getViewportHeight()

module.exports = {
  question:
    big:
      delay: 0
      size: [width - width * .2, width/2]
      classes: ['card__front__question']
      transform: Transform.translate 0, 20, 2.5
#      origin: [0.5, 0.2]
#      align: [0.5, 0.5]
      transition: {duration: 500, curve: Easing.outQuad}
    small:
      delay: 0
      size: [width - width * .4, width/4]
      classes: ['card__front__question--small']
      transform: Transform.translate 30, -130, 2.5
#      origin: [0, 0]
#      align: [0.3, 0.18]
      transition: {duration: 500, curve: Easing.outQuad}
  profilePic:
    size: [100, 100]
    big:
      delay: 0
      transform:  Transform.multiply(
        Transform.scale 1, 1, 1
        Transform.translate 0, -110, 2.5
      )
#      align: [0.5, 0.3]
#      origin: [0.5, 0.5]
      transition: {duration: 500, curve: Easing.outQuad}
      classes: ['card__front__pic--big']
    small:
      delay: 0
      transform: Transform.multiply(
        Transform.scale .5, .5, 1
        Transform.translate -210, -270, 2.5
      )
#      align: [0.1, 0.18]
#      origin: [0, 0]
      transition: {duration: 500, curve: Easing.outQuad}
      classes: ['card__front__pic--small']
  card:
    origin: [0.5, 0.5]
    size: [width - width * .1, height - height * .25]
    transition: {duration: 500, curve: Easing.outQuad}
    front:
      show: Transform.translate 0, 0, 2.5
#      hide: Transform.translate 0,0, -1000
    back:
      transform: Transform.multiply(
        Transform.translate(0, 0, 2.5)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
  answerImage:
    size: [width - 40, null]
    borderRadius: 10
    maxHeight: width - width * .1 - 100
    classes: ['card__back__image']
    transform:  Transform.multiply(
      Transform.translate(0, -100, .5)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  answerText:
    size: [width - 40, 100]
    classes: ['card__back__text']
    transform: Transform.multiply(
      Transform.translate(0, -160, .5)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  addImage:
    size: [43, 48]
    classes: ['card__back__image']
    content: 'images/add-image.png'
    show: Transform.multiply(
      Transform.translate(0, 150, .5)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
    hide: Transform.translate 0,0, -1000
  choices:
    size: [width - width * .1, 260]
    hide: Transform.translate 0, 0, -10
    show: Transform.translate 0, 50, 4
    choice:
      size: [width - width * .1, 65]
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      innerWidth: width - width * .2
  answerPic:
    borderRadius: 10
    size: [width - width * .1, height - height * .25]
}