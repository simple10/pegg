require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Transform = require 'famous/core/Transform'
StateModifier = require 'famous/modifiers/StateModifier'
UserActions = require 'actions/UserActions'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'
Transitionable = require 'famous/transitions/Transitionable'
SpringTransition = require 'famous/transitions/SpringTransition'
Transitionable.registerMethod 'spring', SpringTransition


class LoginView extends View
  @DEFAULT_OPTIONS:
    logoWidth: 150
    logoHeight: 110
    markWidth: 150
    markHeight: 70
    transition:
      duration: 800
      curve: Easing.inOutBack
    spring:
      method: "spring"
      period: 500
      dampingRatio: 0.3

  constructor: (options) ->
    super options
    @initSplash()

  initSplash: ->
    logo = new ImageSurface
      size: [@options.logoWidth, @options.logoHeight]
      classes: ['login__logo']
      content: "images/logo_icon-big.png"
    logoPosMod = new StateModifier
      align: [0.5,1]
      origin: [0.5,0]
    logoSizeMod = new StateModifier
    mark = new ImageSurface
      size: [@options.markWidth, @options.markHeight]
      classes: ['login__mark']
      content: "images/logo_mark-big.png"
    markMod = new StateModifier
      align: [0.5,1]
      origin: [0.5,0]
    @add(logoSizeMod).add(logoPosMod).add logo
    @add(markMod).add mark
    markMod.setTransform Transform.translate(0, -window.innerHeight/2 - @options.logoHeight/2 + @options.markHeight, 3), @options.transition
    Timer.after (=>
      logoPosMod.setTransform Transform.translate(0, -window.innerHeight/2 - @options.logoHeight, 0), @options.spring, =>
        logoSizeMod.setTransform Transform.translate(0, -300, -2000), @options.transition
        markMod.setTransform Transform.translate(0, 0, -30000), {duration: 200}, =>
          @initLogin()
    ), 20

  initLogin: ->
    loginText = new Surface
      size: [68, 60]
      content: 'Login'
      classes: ['login__text--header']
    privacyText = new Surface
      size: [window.innerWidth, 10]
      content: 'Psst... Pegg respects people and their data.'
      classes: ['login__text--message']
    loginTextMod = new StateModifier
      align: [0.5,0.5]
      origin: [0.5,0.5]
      opacity: 0
    node = @add loginTextMod
    node.add loginText
    node.add privacyText
    fbButton = new Surface
      size: [window.innerWidth, window.innerHeight/4]
      content: 'Login with Facebook'
      classes: ['login__button--facebook']
      properties:
        lineHeight: "#{window.innerHeight/4}px"
    fbButtonMod = new StateModifier
      align: [1,0.5]
      origin: [0,0]
    fbButton.on "click", ->
      UserActions.login()
    gpButton = new Surface
      size: [window.innerWidth, window.innerHeight/4]
      content: 'Login with Google'
      classes: ['login__button--google']
      properties:
        lineHeight: "#{window.innerHeight/4}px"
    gpButtonMod = new StateModifier
      align: [1,1]
      origin: [0,1]

    loginTextMod.setOpacity 1, @options.transition
    loginTextMod.setTransform Transform.translate(0, -105, 0), @options.transition
    @add(fbButtonMod).add fbButton
    fbButtonMod.setTransform Transform.translate(-window.innerWidth, 0, 0), @options.transition
    Timer.after (=>
      @add(gpButtonMod).add gpButton
      gpButtonMod.setTransform Transform.translate(-window.innerWidth, 0, 0), @options.transition
    ), 10

# Causes inexplicable flutter near end of animation:
#    Transform.multiply(
#      Transform.scale(.8, .8, 0)
#      Transform.translate(@options.logoWidth/4, -30, 20)
#      Transform.identity
#    ), @options.transition

module.exports = LoginView
