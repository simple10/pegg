require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
InputSurface = require 'famous/surfaces/InputSurface'
StateModifier = require 'famous/modifiers/StateModifier'
UserActions = require 'actions/UserActions'
UserStore = require 'stores/UserStore'
Constants = require 'constants/PeggConstants'
Engine = require 'famous/core/Engine'
MenuActions = require 'actions/MenuActions'
Utils = require 'lib/utils'

class SignupView extends View

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

    Utils.animateAll logoMod, @options.logo.states
    Utils.animateAll markMod, @options.mark.states

    @initSignUp()


  initSignUp: ->
#    signupText = new Surface
#      size: @options.signupText.size
#      content: 'Who\'s got you pegged?'
#      classes: @options.signupText.classes
#    signupTextMod = new StateModifier
#      origin: @options.signupText.origin
#      align: @options.signupText.align
#    @add(signupTextMod).add signupText
    @signupInput = new InputSurface
      size: @options.signupInput.size
      placeholder: 'Enter your email'
      classes: @options.signupInput.classes
      name: 'signup'
    @signupInputMod = new StateModifier
      origin: @options.signupInput.origin
      align: @options.signupInput.align
    @add(signupButtonMod).add signupButton
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

    #Utils.animateAll signupTextMod, @options.signupText.states
    Utils.animateAll signupButtonMod, @options.signupButton.states
    Utils.animateAll @signupInputMod, @options.signupInput.states

    signupButton.on 'click', =>
      @onSubmit()
    @signupInput.on 'click', =>
      @onInputFocus()
    @signupInput.on 'keypress', (e) =>
      if e.keyCode is 13
        @onInputBlur()

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
