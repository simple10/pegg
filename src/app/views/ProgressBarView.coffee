require './scss/play.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Utils = require 'lib/Utils'

class ProgressBarView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportHeight()/2-20
    height: 15
    transition:
      duration: 400
      curve: 'easeOut'

  constructor: (options) ->
    super options
    @last = 0
    @init()

  reset: (steps) =>
    @steps = steps
    @last = 0

  init: ->
    text = new Surface
      content: 'Progress'
      size: [Utils.getViewportWidth(), @options.height]
      classes: ['progressBar__title']
    textMod = new StateModifier
      align: [0.5, 0.03]
      origin: [0.5, 0]
    @activeBar = new ImageSurface
      content: 'images/progress_active.png'
      size: [@last, @options.height]
      properties:
        zIndex: 5
    inactiveBar = new ImageSurface
      content: 'images/progress_inactive.png'
      size: [@options.width, @options.height]
    @activeBarMod = new StateModifier
    inactiveBarMod = new StateModifier
    @add(inactiveBarMod).add inactiveBar
    @add(@activeBarMod).add @activeBar
    @add(textMod).add text

  increment: (x) =>
    step = @options.width / @steps
    next = @last + step * x
    @activeBar.setSize [next, @options.height]
    @last = next



module.exports = ProgressBarView
