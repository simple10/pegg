require './scss/input.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
InputSurface = require 'famous/surfaces/InputSurface'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
Utils = require 'lib/Utils'

class InputView extends View
  @DEFAULT_OPTIONS:
    cssPrefix: 'input__text'

  constructor: (options) ->
    super options
    @init()

  init: =>
    @textInput = new InputSurface
      size: @options.size
      placeholder: @options.placeholder
      classes: ["#{@options.cssPrefix}"]
    @textInputMod = new StateModifier
    @add(@textInputMod).add @textInput

    @textInput.on 'click', =>
      @onInputFocus()
    @textInput.on 'keypress', (e) =>
      if e.keyCode is 13
        @onInputBlur()
        @_eventOutput.emit 'submit', e.currentTarget.value
        @textInput.setValue e.currentTarget.value

  onInputFocus: =>
    @textInput.focus()
    @textInput.setClasses ["#{@options.cssPrefix}--big"]
    @textInput.setSize [Utils.getViewportWidth(), Utils.getViewportHeight()/2 + 50]
    @textInputMod.setAlign [0.5, 0]
    @textInputMod.setOrigin [0.5, 0]
    #@textInputMod.setTransform Transform.translate(0, -Utils.getViewportHeight(), 0), @options.transition

  onInputBlur: =>
    @textInput.blur()
    @textInput.setClasses ["#{@options.cssPrefix}"]
    @textInput.setSize @options.size
    @textInputMod.setAlign @options.align
    @textInputMod.setOrigin @options.origin
    if @options.transform?
      @textInputMod.setTransform @options.transform
    #@textInputMod.setTransform Transform.translate(0, -Utils.getViewportHeight()/2 + 120, 0), @options.transition

  setAlign: (align) =>
    @textInputMod.setAlign align

  getValue: =>
    @textInput.getValue()

  setValue: (value) =>
    @textInput.setValue value

  clear: () =>
    @textInput.setValue ""

module.exports = InputView
