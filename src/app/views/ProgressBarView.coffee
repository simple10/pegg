require './scss/play.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Utils = require 'lib/Utils'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'

class ProgressBarView extends View

  constructor: (options) ->
    super options
    @last = 0
    @init()

  reset: (steps) =>
    @steps = steps
    @last = 0
    @activeBar.setSize [@last, @options.bar.size[1]]
    @percentage.setContent '0%'

  init: ->
    container = new ContainerSurface
      size: @options.size
#    text = new Surface
#      content: 'Progress'
#      size: @options.title.size
#      classes: ['progressBar__title']
#    textMod = new StateModifier
#      align: @options.title.align
#      origin: @options.title.origin
    @activeBar = new ImageSurface
      content: 'images/progress_active.png'
      properties:
        zIndex: 5
    @activeBarMod = new StateModifier
      align: @options.bar.align
      origin: @options.bar.origin
    container.add(@activeBarMod).add @activeBar
    inactiveBar = new ImageSurface
      content: 'images/progress_inactive.png'
      size: @options.bar.size
    inactiveBarMod = new StateModifier
      align: @options.bar.align
      origin: @options.bar.origin
    container.add(inactiveBarMod).add inactiveBar
#    container.add(textMod).add text

    @percentage = new Surface
      size: @options.percentage.size
      classes:  @options.percentage.classes
    percentageMod = new StateModifier
      align:  @options.percentage.align
      origin:  @options.percentage.origin
      transform:  @options.percentage.transform
    @add(percentageMod).add @percentage

    @add container

  increment: (x) =>
    size = @options.size[0]
    step = size / @steps
    next = @last + step * x
    @activeBar.setSize [next, @options.bar.size[1]]
    @percentage.setContent "#{Math.floor(next/size*100)}%"
    @last = next

module.exports = ProgressBarView
