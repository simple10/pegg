require './scss/message.scss'

# Pegg
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'
MessageStore = require 'stores/MessageStore'

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
      transform: @layout.wrapper.transform
    @mainNode = @add(@mainMod)

    @overlay = new Surface
      classes: ["message__overlay"]
    overlayMod = new Modifier
      size: @layout.overlay.size
    @mainNode.add(overlayMod).add @overlay

    @box = new Surface
      classes: ["message__box"]
    boxMod = new Modifier
      size: @layout.box.size
    @mainNode.add(boxMod).add @box

    @text = new Surface
      content: 'Help Text'
      classes: ["message__text"]
    textMod = new Modifier
      size: @layout.text.size
      transform: @layout.text.transform
    @mainNode.add(textMod).add @text

    @okButton = new Surface
      content: 'OK'
      classes: ["message__button"]
    okButtonMod = new Modifier
      size: @layout.okButton.size
      transform: @layout.okButton.transform
    @okButton.on 'click', =>
      @_eventOutput.emit 'hide'
    @mainNode.add(okButtonMod).add @okButton

  load: ->
    @text.setContent MessageStore.getMessage()

module.exports = MessageView
