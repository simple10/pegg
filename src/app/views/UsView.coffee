# Famo.us
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
RenderController = require 'famous/src/views/RenderController'
# RenderNode = require 'famous/src/core/RenderNode'
Scrollview = require 'famous/src/views/Scrollview'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Transform = require 'famous/src/core/Transform'
Transitionable  = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
Utils = require 'lib/Utils'

class UsView extends View
  _insightScrollviewItems: []
  _titleScrollviewItems: []

  constructor: (options) ->
    super options
    @init()

  init: ->
    titleWidth  = Utils.getViewportWidth()
    titleHeight = Utils.getViewportHeight() / 4
    bodyWidth   = Utils.getViewportWidth()
    bodyHeight  = Utils.getViewportHeight() * 3 / 4

    # TITLES
    @titlesScrollview = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: titleWidth
    @titlesScrollview.sequenceFrom @_titleScrollviewItems
    titlesScrollviewMod = new StateModifier
      size: [titleWidth, titleHeight]
      origin: [0.5, 0.0]
      align: [0.5, 0.0]
      transform: Transform.translate null, null, 3
    @add(titlesScrollviewMod).add @titlesScrollview

    titlesBackground = new Surface
      properties:
        backgroundColor: 'red'
    titlesBackground.pipe @titlesScrollview
    titlesBackgroundMod = new StateModifier
      size: [titleWidth, titleHeight]
      origin: [0.5, 0.0]
      align: [0.5, 0.0]
      transform: Transform.translate null, null, 2
    @add(titlesBackgroundMod).add titlesBackground

    for title in ['Insights', 'Activities', 'Lorem Ipsum']
      titleSurface = new Surface
        size: [undefined, true]
        content: title
        properties:
          color: 'white'
          fontSize: '26pt'
          textTransform: 'uppercase'
      titleContainer = new ContainerSurface
        size: [undefined, undefined]
      titleMod = new StateModifier
        origin: [0.0, 1.0]
        align: [0.0, 1.0]
        transform: Transform.translate null, 200, 3
      # titleSurface.mod = titleMod
      titleSurface.pipe @titlesScrollview
      @_titleScrollviewItems.push titleContainer.add(titleMod).add(titleSurface)

    # INSIGHTS
    @insightsScrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: true
    @insightsScrollview.sequenceFrom @_insightScrollviewItems
    insightsScrollviewMod = new StateModifier
      size: [bodyWidth, bodyHeight]
      align: [0.5, 1.0]
      origin: [0.5, 1.0]
    @add(insightsScrollviewMod).add @insightsScrollview

    for i in [1..3]
      surface = new Surface
        content: "Insight ##{i}"
        properties:
          textAlign: 'center'
          color: 'white'
          fontSize: '20pt'
          textTransform: 'uppercase'
          paddingTop: '2em'
      surface.pipe @insightsScrollview
      @_insightScrollviewItems.push surface

module.exports = UsView
