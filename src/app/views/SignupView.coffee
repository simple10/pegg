require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
InputSurface = require 'famous/surfaces/InputSurface'
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
Engine = require 'famous/core/Engine'
MenuActions = require 'actions/MenuActions'

class SignupView extends View
  window:
    height: null

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
      period: 300
      dampingRatio: 0.3
    input:
      width: 300
      height: 40


  #Engine.on "keydown", (e) =>
  #  if e.which is 13
  #    UserActions.subscribe "play"

  constructor: (options) ->
    super options
    @window.height = window.innerHeight
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
    markMod.setTransform Transform.translate(0, -@window.height/2 - @options.logoHeight/2 + @options.markHeight, 3), @options.transition
    Timer.after (=>
      logoPosMod.setTransform Transform.translate(0, -@window.height/2 - @options.logoHeight, 0), @options.spring, =>
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
    @signupInput = new InputSurface
      size: [@options.input.width, @options.input.height]
      placeholder: "Enter your email"
      classes: ["signup__email__input"]
      name: "signup"
    @signupInputMod = new StateModifier
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
    @add(@signupInputMod).add @signupInput
    @add(signupTextMod).add signupText
    @add(signupSubmitMod).add signupSubmit
    signupTextMod.setTransform Transform.translate(0, @window.height/2 + 60, 3), @options.transition, =>
      @signupInputMod.setTransform Transform.translate(0, @window.height/2 + 120, 3), @options.transition, =>
        signupSubmitMod.setTransform Transform.translate(0, @window.height/2 + 170, 3), @options.transition, =>

    signupSubmit.on "click", =>
      @onSubmit()
    @signupInput.on "click", =>
      @onInputFocus()
    @signupInput.on "keypress", (e) =>
      if e.keyCode is 13
        @onInputBlur()

  onSubmit: =>
    email = @signupInput.getValue()
    @signupInput.setValue ""
    UserActions.subscribe email

  onInputFocus: =>
    @signupInput.focus()
    @signupInput.setClasses ["signup__email__input--big"]
    @signupInputMod.setTransform Transform.translate(0, @options.input.height*2, 0), @options.transition

  onInputBlur: =>
    @signupInput.blur()
    @signupInput.setClasses ["signup__email__input"]
    @signupInputMod.setTransform Transform.translate(0, @window.height/2 + 120, 0), @options.transition


  closeInput: =>
    alert "close"

  showMessage: =>
    if UserStore.getSubscriptionStatus()
      message = 'We agree! Welcome.'
      classes = ['signup__response--success']

    else
      message = 'Nah, guess not. Fail.'
      classes = ['signup__response--fail']
    messageText = new Surface
      size: [300, 60]
      content: message
      classes: classes
    messageMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.07]
    @add(messageMod).add messageText
    messageMod.setTransform Transform.translate(0, window.innerHeight/2 + 230, 3), @options.transition, =>



module.exports = SignupView
