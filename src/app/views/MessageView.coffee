require './scss/message.scss'

# Pegg
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'
MessageStore = require 'stores/MessageStore'

# Famo.us
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Modifier = require 'famous/src/core/Modifier'
Transform = require 'famous/src/core/Transform'
Easing = require 'famous/src/transitions/Easing'
RenderController = require 'famous/src/views/RenderController'

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
    @boxMod = new Modifier
      size: @layout.box.size
      origin: @layout.box.origin
      align: @layout.box.align
    @mainNode.add(@boxMod).add @box

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
    @okButtonRc = new RenderController
    @okButtonMod = new Modifier
      size: @layout.okButton.size
      transform: @layout.okButton.transform
    @okButton.on 'click', =>
      @_eventOutput.emit 'hide'
    @mainNode.add(@okButtonMod).add @okButtonRc
    @okButtonRc.show @okButton

  load: (payload) =>
    if payload.type is 'loading'
      payload.message = 'loading...'
      @okButtonRc.hide @okButton
      @boxMod.setOpacity 0
      @okButtonMod.setOpacity 0
      @text.setClasses ['message__text--loading']
    else
      @text.setClasses ["message__text"]
      @okButtonRc.show @okButton
      @okButtonMod.setOpacity 1
      @boxMod.setOpacity 1
    @text.setContent payload.message

module.exports = MessageView
