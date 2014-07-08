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
UserStore = require 'stores/UserStore'
Constants = require 'constants/PeggConstants'
Engine = require 'famous/core/Engine'
MenuActions = require 'actions/MenuActions'
Transitionable  = require 'famous/transitions/Transitionable'
TweenTransition = require 'famous/transitions/TweenTransition'

class SignupView extends View

  @DEFAULT_OPTIONS:

    logo:
      size: [417, 800]
      classes: ['login__logo']
      align: [0.5, 1]
      origin: [0.5, 0]
      states: [
        {
          delay: 10
          align: [0.45, 0.5]
          transition: {duration: 1000, curve: Easing.inBounce}
        }
        {
          delay: 100
          align: [0.45, 0]
          scale: [0.4, 0.4, 0]
          transition: {duration: 500, curve: Easing.outBounce}
        }
      ]

    mark:
      size: [150, 70]
      classes: ['login__mark']
      align: [0.5, 1]
      origin: [0.5, 1]
      states: [
        {
          delay: 35
          align: [0.5, 0.5]
          origin: [0.5, 0.5]
          transition: {duration: 500, curve: Easing.inOutBack}
        }
        {
          delay: 100
          align: [0.5, 0.6]
          origin: [0.5, 0]
          transition: {duration: 500, curve: Easing.outBounce}
        }
      ]

    signupText:
      size: [300, 50]
      classes: ['signup__text--header']
      align: [0.5, 1]
      origin: [0.5, 0]
      states: [
        {
          delay: 100
          align: [0.5, .7]
          origin: [0.5, 0.5]
          transition: {duration: 1000, curve: Easing.outBounce}
        }
      ]

    signupInput:
      size: [300, 50]
      classes: ['signup__email__input']
      align: [0.5, 1]
      origin: [0.5, 0]
      states: [
        {
          delay: 120
          align: [0.5, 0.8]
          origin: [0.5, 0.5]
          transition: {duration: 1000, curve: Easing.outBounce}
        }
      ]

    signupButton:
      size: [300, 50]
      classes: ['signup__submit']
      align: [0.5, 1]
      origin: [0.5, 0]
      states: [
        {
          delay: 120
          align: [0.5, 0.9]
          origin: [0.5, 0.5]
          transition: {duration: 1000, curve: Easing.outBounce}
        }
      ]

    signupMessage:
      size: [300, 50]
      classes: ['signup__response']
      origin: [0.5, 0.5]
      align: [0.5, -0.07]
      states: [
        {
          align: [0.5, 1]
          origin: [0.5, 0.5]
          transition: {duration: 1000, curve: Easing.outBounce}
        }
      ]

  #Engine.on "keydown", (e) =>
  #  if e.which is 13
  #    UserActions.subscribe "play"

  constructor: (options) ->
    super options
    @initListeners()
    @initSplash()


  initListeners: ->
    UserStore.on Constants.stores.SUBSCRIBE_PASS, @showMessage
    UserStore.on Constants.stores.SUBSCRIBE_FAIL, @showMessage

  initSplash: ->
    logoSurface = new ImageSurface
      size: @options.logo.size
      classes: @options.logo.classes
      content: "images/mascot_medium.png"
    logoMod = new StateModifier
      origin: @options.logo.origin
      align: @options.logo.align
    markSurface = new ImageSurface
      size: @options.mark.size
      classes: @options.mark.classes
      content: "images/logo_mark-big.png"
    markMod = new StateModifier
      origin: @options.mark.origin
      align: @options.mark.align
    @add(logoMod).add logoSurface
    @add(markMod).add markSurface

    @animate logoMod, @options.logo.states
    @animate markMod, @options.mark.states

    @initSignUp()


  initSignUp: ->
    signupText = new Surface
      size: @options.signupText.size
      content: 'Who\'s got you pegged?'
      classes: @options.signupText.classes
    signupTextMod = new StateModifier
      origin: @options.signupText.origin
      align: @options.signupText.align
    @signupInput = new InputSurface
      size: @options.signupInput.size
      placeholder: 'Enter your email'
      classes: @options.signupInput.classes
      name: 'signup'
    @signupInputMod = new StateModifier
      origin: @options.signupInput.origin
      align: @options.signupInput.align
    signupButton = new Surface
      size: @options.signupButton.size
      content: 'I\'m sexy and I know it.'
      classes: @options.signupButton.classes
      properties:
        lineHeight: "#{@options.signupButton.size[1]}px"
    signupButtonMod = new StateModifier
      origin: @options.signupButton.origin
      align:  @options.signupButton.align
    @add(@signupInputMod).add @signupInput
    #@add(signupTextMod).add signupText
    @add(signupButtonMod).add signupButton

    #@animate signupTextMod, @options.signupText.states
    @animate signupButtonMod, @options.signupButton.states
    @animate @signupInputMod, @options.signupInput.states

    signupButton.on 'click', =>
      @onSubmit()
    @signupInput.on 'click', =>
      @onInputFocus()
    @signupInput.on 'keypress', (e) =>
      if e.keyCode is 13
        @onInputBlur()

  animate: (mod, states) ->
    for state in states
      Timer.after ((mod, state)->
        if state.origin
          mod.setOrigin state.origin, state.transition
        if state.align
          mod.setAlign state.align, state.transition
        if state.scale
          mod.setTransform Transform.scale(state.scale...), state.transition
      ).bind(@, mod, state), state.delay

  onSubmit: =>
    email = @signupInput.getValue()
    @signupInput.setValue ""
    UserActions.subscribe email

  onInputFocus: =>
    @signupInput.focus()
    ###@signupInput.setClasses ["signup__email__input--big"]
    @signupInput.setSize [window.innerWidth, window.innerHeight/2 + 50]
    @signupInputMod.setAlign [0.5, 0]
    @signupInputMod.setOrigin [0.5, 1]###

  onInputBlur: =>
    @signupInput.blur()
    ###@signupInput.setClasses ["signup__email__input"]
    @signupInputMod.setTransform Transform.translate(0, @window.height/2 + 120, 0), @options.transition
    @signupInput.setSize [@options.input.width, @options.input.height]
    @signupInputMod.setAlign [0.5, 1]
    @signupInputMod.setOrigin [0.5, 0]###

  closeInput: =>
    alert "close"

  showMessage: =>
    if UserStore.getSubscriptionStatus()
      message = 'We agree! Welcome.'
      classes = ["#{@options.signupMessage.classes}--success"]
    else
      message = 'Nah, guess not. Fail.'
      classes = ["#{@options.signupMessage.classes}--fail"]
    messageText = new Surface
      size: @options.signupMessage.size
      content: message
      classes: classes
    messageMod = new StateModifier
      origin: @options.signupMessage.origin
      align: @options.signupMessage.align
    @add(messageMod).add messageText
    messageMod.setAlign @options.signupMessage.states[0].align, @options.signupMessage.states[0].transition


module.exports = SignupView
