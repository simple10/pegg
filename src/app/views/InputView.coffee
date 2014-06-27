require './scss/input.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
InputSurface = require 'famous/surfaces/InputSurface'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'

class InputView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth - window.innerWidth * .1
    height: 50
    placeholder: 'hello'
    cssPrefix: 'input__text'
    name: 'generic'
    transition:
      duration: 500
      curve: Easing.outBounce

  constructor: (options) ->
    super options
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
    @textInput.setSize [window.innerWidth, window.innerHeight/2 + 50]
    @textInputMod.setAlign [0.5, 0]
    #@textInputMod.setTransform Transform.translate(0, -window.innerHeight, 0), @options.transition

  onInputBlur: =>
    @textInput.blur()
    @textInput.setClasses ["#{@options.cssPrefix}"]
    @textInput.setSize [@options.width, @options.height]
    @textInputMod.setAlign [0.5, 1]
    #@textInputMod.setTransform Transform.translate(0, -window.innerHeight/2 + 120, 0), @options.transition



module.exports = InputView
