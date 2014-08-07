require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
UserActions = require 'actions/UserActions'
Utils = require 'lib/Utils'


class LoginView extends View

  constructor: (options) ->
    super options
    @initSplash()
    @initLogin()

  initSplash: ->
    logo = new ImageSurface
      size: @options.logo.size
      classes: @options.logo.classes
      content: "images/cosmic-unicorn-head-circle.svg"
    logoMod = new StateModifier
      align: @options.logo.align
      origin: @options.logo.origin
#    mark = new ImageSurface
#      size: @options.mark.size
#      classes: @options.mark.classes
#      content: "images/pegg.svg"
#    markMod = new StateModifier
#      align: @options.mark.align
#      origin: @options.mark.origin
    text = new Surface
      size: @options.text.size
      classes: @options.text.classes
      content: "LOGIN"
    textMod = new StateModifier
      align: @options.text.align
      origin: @options.text.origin

    @add(logoMod).add logo
    @add(textMod).add text

    Utils.animateAll logoMod, @options.logo.states
    Utils.animateAll textMod, @options.text.states

  initLogin: ->
    fbButton = new Surface
      size: @options.fbButton.size
      content: 'Login with Facebook'
      classes: @options.fbButton.classes
      properties:
        lineHeight: "#{@options.fbButton.size[1]}px"
    fbButtonMod = new StateModifier
      align: @options.fbButton.align
      origin: @options.fbButton.origin
    fbButton.on "click", ->
      UserActions.login()
    gpButton = new Surface
      size: @options.gpButton.size
      content: 'Login with Google'
      classes: @options.gpButton.classes
      properties:
        lineHeight: "#{@options.gpButton.size[1]}px"
    gpButtonMod = new StateModifier
      align: @options.gpButton.align
      origin: @options.gpButton.origin
    @add(fbButtonMod).add fbButton
    @add(gpButtonMod).add gpButton

    Utils.animateAll fbButtonMod, @options.fbButton.states
    Utils.animateAll gpButtonMod, @options.gpButton.states



#    loginText = new Surface
#      size: [68, 60]
#      content: 'Login'
#      classes: ['login__text--header']
#    privacyText = new Surface
#      size: [Utils.getViewportWidth(), 10]
#      content: 'Psst... Pegg respects people and their data.'
#      classes: ['login__text--message']
#    loginTextMod = new StateModifier
#      align: [0.5,0.5]
#      origin: [0.5,0.5]
#      opacity: 0
#    node = @add loginTextMod
#    node.add loginText
#    node.add privacyText


# Causes inexplicable flutter near end of animation:
#    Transform.multiply(
#      Transform.scale(.8, .8, 0)
#      Transform.translate(@options.logoWidth/4, -30, 20)
#      Transform.identity
#    ), @options.transition

module.exports = LoginView
