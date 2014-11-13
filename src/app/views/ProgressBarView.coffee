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

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    @init()

  reset: (steps) =>
    @steps = steps
    @activeBar.setSize [4, @layout.progress.size[1]]

  init: ->
    @activeBar = new ImageSurface
      content: 'images/progress_active.png'
      classes: @layout.progress.active.classes
    @activeBarMod = new StateModifier
      align: @layout.progress.align
      origin: @layout.progress.origin
      transform: @layout.progress.active.transform
    @add(@activeBarMod).add @activeBar

    inactiveBar = new ImageSurface
      content: 'images/progress_inactive.png'
      size: @layout.progress.size
    inactiveBarMod = new StateModifier
      align: @layout.progress.align
      origin: @layout.progress.origin
      transform: @layout.progress.transform
    @add(inactiveBarMod).add inactiveBar

  setPosition: (x) =>
    size = @layout.progress.size[0]
    step = size / @steps
    next = x * step
    @activeBar.setSize [next, @layout.progress.size[1]]

module.exports = ProgressBarView
