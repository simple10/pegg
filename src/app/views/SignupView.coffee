require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
InputView = require 'views/InputView'
StateModifier = require 'famous/modifiers/StateModifier'
UserActions = require 'actions/UserActions'
UserStore = require 'stores/UserStore'
Constants = require 'constants/PeggConstants'
Engine = require 'famous/core/Engine'
NavActions = require 'actions/NavActions'
Utils = require 'lib/Utils'

class SignupView extends View

  #Engine.on "keydown", (e) =>
  #  if e.which is 13
  #    UserActions.subscribe "play"

  constructor: (options) ->
    super options
    @letmeinCount = 0
    @initListeners()
    @initSplash()

  initListeners: ->
    UserStore.on Constants.stores.SUBSCRIBE_PASS, @showMessage
    UserStore.on Constants.stores.SUBSCRIBE_FAIL, @showMessage

  initSplash: ->
    logoSurface = new ImageSurface
      size: @options.logo.size
      classes: @options.logo.classes
      content: "images/cosmic-unicorn-head-circle.svg"
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

    logoSurface.on 'click', =>
      NavActions.selectMenuItem 'login'

  initSignUp: ->
#    signupText = new Surface
#      size: @options.signupText.size
#      content: 'Who\'s got you pegged?'
#      classes: @options.signupText.classes
#    signupTextMod = new StateModifier
#      origin: @options.signupText.origin
#      align: @options.signupText.align
#    @add(signupTextMod).add signupText
    @signupInput = new InputView
      size: @options.signupInput.size
      placeholder: 'Enter your email'
      classes: @options.signupInput.classes
    @signupInputMod = new StateModifier
      origin: @options.signupInput.origin
      align: @options.signupInput.align
    @add(@signupInputMod).add @signupInput

    signupButton = new Surface
      size: @options.signupButton.size
      content: 'I\'m sexy and I know it.'
      classes: @options.signupButton.classes
      properties:
        lineHeight: "#{@options.signupButton.size[1]}px"
    signupButtonMod = new StateModifier
      origin: @options.signupButton.origin
      align:  @options.signupButton.align
    @add(signupButtonMod).add signupButton

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

  showMessage: =>
    if UserStore.getSubscriptionStatus()
      message = 'Ooh, yeah! ttyl.'
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
