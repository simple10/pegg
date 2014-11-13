Easing = require 'famous/src/transitions/Easing'
Transform = require 'famous/src/core/Transform'
Utils = require 'lib/Utils'

width = Utils.getViewportWidth()
height = Utils.getViewportHeight()

module.exports = {
  question:
    big:
      delay: 0
      size: [width - 50, 150]
      classes: ['card__front__question']
      transform: Transform.translate 0, 230, 3
      transition: {duration: 200, curve: Easing.outQuad}
    small:
      delay: 0
      size: [width - 120, 75]
      classes: ['card__front__question--small']
      transform: Transform.translate 30, 80, 3
#      origin: [0, 0]
#      align: [0.3, 0.18]
      transition: {duration: 200, curve: Easing.outQuad}
  profilePic:
    size: [100, 100]
    big:
      delay: 0
      transform:  Transform.multiply(
        Transform.scale 1, 1, 1
        Transform.translate 0, 100, 3
      )
#      align: [0.5, 0.3]
#      origin: [0.5, 0.5]
      transition: {duration: 300, curve: Easing.outQuad}
      classes: ['card__front__pic--big']
    small:
      delay: 0
      transform: Transform.multiply(
        Transform.scale .5, .5, 1
        Transform.translate -(width / 6) * 4 , height / 4 , 3
      )
#      align: [0.1, 0.18]
#      origin: [0, 0]
      transition: {duration: 300, curve: Easing.outQuad}
      classes: ['card__front__pic--small']
  card:
    origin: [0.5, 0]
    align: [0.5, 0]
    size: [width - 20, height - 150]
    transition: {duration: 1000, curve: Easing.outQuad}
    front:
      transform: Transform.translate 0, 55, 2
#      hide: Transform.translate 0,0, -1000
    back:
      transform: Transform.multiply(
        Transform.translate(0, 55, -2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
  answerImage:
    size: [width - 23, null]
    borderRadius: 10
    maxHeight: width - width * .1 - 100
#    maxWidth: width - 60
    classes: ['card__back__image']
    transform:  Transform.multiply(
      Transform.translate(0, 200, -3)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  answerText:
    size: [width - 60, 100]
    classes: ['card__back__text']
    transform: Transform.multiply(
      Transform.translate(0, 75, -3)
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  addImage:
    size: [43, 48]
    classes: ['card__back__addImage']
    content: 'images/add-image.png'
    origin: [0.5, 0.5]
    align: [0.5, 0.5]
    transform: Transform.multiply(
      Transform.translate 0, height - 160, 1
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  commentButton:
    size: [35, 35]
    classes: ['card__back__commentButton']
    content: 'images/comment-icon.svg'
    transform: Transform.multiply(
      Transform.translate width / 2.5, height - 150, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  commentCount:
    size: [35, 35]
    classes: ['card__back__commentCount']
    transform: Transform.multiply(
      Transform.translate width / 2.5 - 40, height - 145, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  heartButton:
    size: [35, 35]
    classes: ['card__back__heartButton']
    content: 'images/heart-icon.svg'
    transform: Transform.multiply(
      Transform.translate width / 7, height - 150, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  heartCount:
    size: [35, 35]
    classes: ['card__back__heartCount']
    transform: Transform.multiply(
      Transform.translate width / 7 - 40, height - 145, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  shareButton:
    size: [35, 35]
    classes: ['card__back__shareButton']
    content: 'images/share-icon.svg'
    transform: Transform.multiply(
      Transform.translate -(width / 7), height - 150, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  shareCount:
    size: [35, 35]
    classes: ['card__back__shareCount']
    transform: Transform.multiply(
      Transform.translate -(width / 7 + 35), height - 145, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  moreButton:
    size: [35, 35]
    classes: ['card__back__moreButton']
    content: 'images/more-icon.svg'
    transform: Transform.multiply(
      Transform.translate -(width / 2.5), height - 150, -3
      Transform.multiply(
        Transform.rotateZ Math.PI
        Transform.rotateX Math.PI
      )
    )
  choices:
    size: [width - width * .1, height - 300]
#    align: [null, 0.5]
#    origin: [undefined, 0.5]
    show: Transform.translate 0, 180, 3
    hide: Transform.translate 0, 180, 3
    choice:
      size: [width - width * .1, 65]
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      innerWidth: width - width * .2
      height: 60
    inTransition:  { duration: 50, curve: Easing.outCubic }
    outTransition: { duration: 50, curve: Easing.outCubic }
  answerPic:
    borderRadius: 10
    size: [width - width * .1, height - height * .25]
}
