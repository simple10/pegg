
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

  increment: (x) =>
    step = @options.width / @steps
    next = @last + step * x
    @activeBar.setSize [next, @options.height]
    @last = next

module.exports = ProgressBarView
