require './scss/message.scss'

# Pegg
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'

# Famo.us
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'

class MessageView extends View
  constructor: ->
    super
    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'MessageView'
    @init()

  init: ->

    @mainMod = new Modifier
      origin: @layout.wrapper.origin
      align: @layout.wrapper.align

    @okButton = new Surface
      content: ''
    okButtonMod = new Modifier
      size: @layout.okButton.size
      transform: @layout.okButton.transform
    @mainMod.add(okButtonMod).add @okButton

    @text = new Surface
      content: ''
    textMod = new Modifier
      size: @layout.text.size
      transform: @layout.text.transform
    @mainMod.add(textMod).add @text

    @add @mainMod

module.exports = MessageView
