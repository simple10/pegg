require './scss/input.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
InputSurface = require 'famous/src/surfaces/InputSurface'
Transform = require 'famous/src/core/Transform'
Easing = require 'famous/src/transitions/Easing'
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
      classes: ["#{@options.cssPrefix}", "#{@options.classes}"]
      properties: @options.properties
    @textInputMod = new StateModifier
    @add(@textInputMod).add @textInput

    @textInput.on 'click', =>
      @onInputFocus()
    @textInput.on 'keypress', (e) =>
      switch e.keyCode
        when 13 #enter
          @onInputBlur()
          if e.currentTarget.value
            @_eventOutput.emit 'submit', e.currentTarget.value
            @textInput.setValue e.currentTarget.value
        when 27 #escape FIXME
          @onInputBlur()

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
    @.textInput._currentTarget.value = ""

module.exports = InputView
