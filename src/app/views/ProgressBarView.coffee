require './scss/play.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
Utils = require 'lib/Utils'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
SequentialLayout = require 'famous/src/views/SequentialLayout'

LayoutManager = require 'views/layouts/LayoutManager'

class ProgressBarView extends View

  constructor: (options) ->
    super options
    @last = 0

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayNavView'

    @init()

  reset: (steps) =>
    @steps = steps
    @last = 0
    @activeBar.setSize [@last, @layout.progress.bar.size[1]]
    @percentage.setContent '0%'

  init: ->
    container = new ContainerSurface
      size: @layout.progress.size

    @activeBar = new ImageSurface
      content: 'images/progress_active.png'
      classes: @layout.progress.bar.active.classes
    @activeBarMod = new StateModifier
      align: @layout.progress.bar.align
      origin: @layout.progress.bar.origin
    container.add(@activeBarMod).add @activeBar

    inactiveBar = new ImageSurface
      content: 'images/progress_inactive.png'
      size: @layout.progress.bar.size
    inactiveBarMod = new StateModifier
      align: @layout.progress.bar.align
      origin: @layout.progress.bar.origin
    container.add(inactiveBarMod).add inactiveBar

    @percentage = new Surface
      size: @layout.progress.percentage.size
      classes:  @layout.progress.percentage.classes
    percentageMod = new StateModifier
      align:  @layout.progress.percentage.align
      origin:  @layout.progress.percentage.origin
      transform:  @layout.progress.percentage.transform
    @add(percentageMod).add @percentage

    @add container

  increment: (x) =>
    size = @layout.progress.size[0]
    step = size / @steps
    next = @last + step * x
    @activeBar.setSize [next, @layout.progress.bar.size[1]]
    @percentage.setContent "#{Math.floor(next/size*100)}%"
    @last = next

module.exports = ProgressBarView
