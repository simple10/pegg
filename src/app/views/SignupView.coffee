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
UserStore = require 'stores/UserStore'
Constants = require 'constants/PeggConstants'


class SignupView extends View
  @DEFAULT_OPTIONS:
    logoWidth: 165
    logoHeight: 122
    markWidth: 150
    markHeight: 70
    transition:
      duration: 500
      curve: Easing.outBounce
    spring:
      method: "spring"
      period: 500
      dampingRatio: 0.3
    input:
      width: 300
      height: 40

  constructor: (options) ->
    super options
    @initListeners()
    @initSplash()

  initListeners: ->
    UserStore.on Constants.stores.SUBSCRIBE_PASS, @showMessage
    UserStore.on Constants.stores.SUBSCRIBE_FAIL, @showMessage

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
    markSizeMod = new StateModifier
    @add(logoSizeMod).add(logoPosMod).add logo
    @add(markSizeMod).add(markMod).add mark
    markMod.setTransform Transform.translate(0, -window.innerHeight/2 - @options.logoHeight/2 + @options.markHeight, 3), @options.transition
    Timer.after (=>
      logoPosMod.setTransform Transform.translate(0, -window.innerHeight/2 - @options.logoHeight, 0), @options.spring, =>
        Timer.after (=>
          markSizeMod.setTransform Transform.translate(0, -200, -1000), {duration: 500, curve: Easing.inOutBack}
        ), 20
        logoSizeMod.setTransform Transform.translate(0, -200, -1000), {duration: 500, curve: Easing.inOutBack}, =>
          @initSignUp()
    ), 20

  initSignUp: ->
    signupText = new Surface
      size: [300, 60]
      content: 'Coming soon.'
      classes: ['signup__text--header']
    signupTextMod = new StateModifier
      origin: [0.5, 1]
      align: [0.5, -0.05]
    signupEmail = new Surface
      size: [300, 40]
      content: '<input type="text" name="question" placeholder="Enter your email" id="email" required/>'
      classes: ["signup__email__input"]
    signupEmailMod = new StateModifier
      origin: [0.5, 1]
      align: [0.5, -0.05]
    signupSubmit = new Surface
      size: [@options.input.width, @options.input.height]
      content: 'I\'m sexy and I know it.'
      classes: ['signup__submit']
      properties:
        lineHeight: @options.input.height + "px"
    signupSubmitMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.07]
    @add(signupEmailMod).add signupEmail
    @add(signupTextMod).add signupText
    @add(signupSubmitMod).add signupSubmit
    signupTextMod.setTransform Transform.translate(0, window.innerHeight/2 + 60, 3), @options.transition, =>
      signupEmailMod.setTransform Transform.translate(0, window.innerHeight/2 + 120, 3), @options.transition, =>
        signupSubmitMod.setTransform Transform.translate(0, window.innerHeight/2 + 170, 3), @options.transition, =>

    signupSubmit.on "click", =>
      @onSubmit()

  onSubmit: =>
    email = document.getElementById('email').value
    UserActions.subscribe email

  showMessage: =>
    if UserStore.getSubscriptionStatus()
      message = "Successfully subscribed!"
    else
      message = "Subscription fail..."
    messageText = new Surface
      size: [300, 60]
      content: message
      classes: ['signup__text--header']
    messageMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 1]
    @add(messageMod).add messageText



module.exports = SignupView
