require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
UserActions = require 'actions/UserActions'
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'


class LoginView extends View

  constructor: (options) ->
    super options
    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'LoginView'

    @initSplash()
    @initLogin()

  initSplash: ->
    logo = new ImageSurface
      size: @layout.logo.size
      classes: @layout.logo.classes
      content: "images/cosmic-unicorn-noback.svg"
    logoMod = new StateModifier
      align: @layout.logo.align
      origin: @layout.logo.origin
#    mark = new ImageSurface
#      size: @options.mark.size
#      classes: @options.mark.classes
#      content: "images/pegg.svg"
#    markMod = new StateModifier
#      align: @options.mark.align
#      origin: @options.mark.origin
    text = new Surface
      size: @layout.text.size
      classes: @layout.text.classes
      content: "LOGIN"
    textMod = new StateModifier
      align: @layout.text.align
      origin: @layout.text.origin

    @add(logoMod).add logo
    @add(textMod).add text

    Utils.animateAll logoMod, @layout.logo.states
    Utils.animateAll textMod, @layout.text.states

  initLogin: ->
    fbButton = new Surface
      size: @layout.fbButton.size
      content: 'Login with Facebook'
      classes: @layout.fbButton.classes
      properties:
        lineHeight: "#{@layout.fbButton.size[1]}px"
    fbButtonMod = new StateModifier
      align: @layout.fbButton.align
      origin: @layout.fbButton.origin
    fbButton.on "click", ->
      UserActions.login()
    gpButton = new Surface
      size: @layout.gpButton.size
      content: 'Login with Google'
      classes: @layout.gpButton.classes
      properties:
        lineHeight: "#{@layout.gpButton.size[1]}px"
    gpButtonMod = new StateModifier
      align: @layout.gpButton.align
      origin: @layout.gpButton.origin
    @add(fbButtonMod).add fbButton
    @add(gpButtonMod).add gpButton

    Utils.animateAll fbButtonMod, @layout.fbButton.states
    Utils.animateAll gpButtonMod, @layout.gpButton.states



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
#      Transform.translate(@layout.logoWidth/4, -30, 20)
#      Transform.identity
#    ), @layout.transition

module.exports = LoginView
