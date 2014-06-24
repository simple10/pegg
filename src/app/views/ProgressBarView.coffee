
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'

class ProgressBarView extends View
  @DEFAULT_OPTIONS:
    width: window.innerHeight/2-20
    height: 15
    transition:
      duration: 400
      curve: 'easeOut'

  constructor: (steps, options) ->
    super options
    #debugger
    @steps = steps
    @last = 0
    @init()

  init: ->
    progressBarMod = new StateModifier
    @mainNode = @add progressBarMod
    text = new Surface
      content: "Progress"
      size: [@options.width, @options.height]
    textMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
    @activeBar = new ImageSurface
      content: "images/progress_active.png"
      size: [@last, @options.height]
      properties:
        zIndex: 10
    inactiveBar = new ImageSurface
      content: "images/progress_inactive.png"
      size: [@options.width, @options.height]
    @activeBarMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
    inactiveBarMod = new StateModifier
    @mainNode.add(inactiveBarMod).add inactiveBar
    @mainNode.add(@activeBarMod).add @activeBar
    @mainNode.add(textMod).add text

  increment: (x) =>
    step = @options.width / @steps
    next = @last + step * x
    @activeBar.setSize [next, @options.height]
    @last = next

module.exports = ProgressBarView
