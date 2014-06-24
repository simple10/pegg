require './scss/input.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
InputSurface = require 'famous/surfaces/InputSurface'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'

class InputView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth - window.innerWidth * .2
    height: 50
    placeholder: 'hello'
    cssPrefix: 'input__text'
    name: 'generic'
    transition:
      duration: 500
      curve: Easing.outBounce

  constructor: () ->
    super
    @init()

  init: =>
    @textInput = new InputSurface
      size: [@options.width, @options.height]
      placeholder: @options.placeholder
      classes: ["#{@options.cssPrefix}"]
    @textInputMod = new StateModifier
    @add(@textInputMod).add @textInput
    @textInput.on 'click', =>
      @onInputFocus()
    @textInput.on 'keypress', (e) =>
      if e.keyCode is 13
        @onInputBlur()
        @_eventOutput.emit 'submit', @textInput.getValue()

  onInputFocus: =>
    @textInput.focus()
    @textInput.setClasses ["#{@options.cssPrefix}--big"]
    @textInputMod.setTransform Transform.translate(0, -window.innerHeight/2, 0), @options.transition

  onInputBlur: =>
    @textInput.blur()
    @textInput.setClasses ["#{@options.cssPrefix}"]
    @textInputMod.setTransform Transform.translate(0, -window.innerHeight/2 + 120, 0), @options.transition



module.exports = InputView