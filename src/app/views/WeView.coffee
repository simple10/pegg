# Famo.us
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
RenderController = require 'famous/src/views/RenderController'
RenderNode = require 'famous/src/core/RenderNode'
Scrollview = require 'famous/src/views/Scrollview'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Transform = require 'famous/src/core/Transform'
Transitionable  = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
ActivityView = require 'views/ActivityView'
InsightsView = require 'views/InsightsView'
LayoutManager = require 'views/layouts/LayoutManager'
Utils = require 'lib/Utils'

class WeView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @footerLayout = @layoutManager.getViewLayout 'FooterView'

    @initRenderables()
    @initGestures()

  initRenderables: ->
    containerHeight = Utils.getViewportHeight() - @footerLayout.height
    containerWidth = Utils.getViewportWidth()
    titleWidthRatio = 2 / 3
    titleHeightRatio = 1 / 4
    bodyHeightRatio = 1 - titleHeightRatio
    @titleWidth  = containerWidth * titleWidthRatio
    @titleHeight = containerHeight * titleHeightRatio
    @bodyWidth   = containerWidth
    @bodyHeight  = containerHeight  * bodyHeightRatio
    @ratio = @titleWidth / @bodyWidth

    ## TITLES ##
    @_titlesScrollviewItems = []
    @titlesScrollview = new Scrollview
      direction: Utility.Direction.X
      paginated: true
    @titlesScrollview.sequenceFrom @_titlesScrollviewItems
    titlesScrollviewMod = new StateModifier
      size: [@titleWidth, @titleHeight]
      # proportions: [titleWidthRatio, titleHeightRatio]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
    @add(titlesScrollviewMod).add @titlesScrollview

    titlesBackground = new Surface
    titlesBackground.pipe @titlesScrollview
    titlesBackgroundMod = new StateModifier
      size: [@bodyWidth, @titleHeight]
      # proportions: [1, titleHeightRatio]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
      transform: Transform.translate null, null, 1
    @add(titlesBackgroundMod).add titlesBackground

    marginX = 0.06

    rainbowSurface = new ImageSurface
      size: [70, 70]
      content: 'images/rainbow-circle-slice.svg'
    rainbowSurfaceMod = new StateModifier
      origin: [0.5, 0.05]
      align: [0.5, 0.05]
    @add(rainbowSurfaceMod).add(rainbowSurface)

    hrSurface = new Surface
      size: [@bodyWidth * ( 1 - marginX * 2), 0]
      # proportions: [1 - ( marginX * 2 ), 0.01]
      properties:
        borderBottom: '1px solid white'
    hrSurface.pipe @titlesScrollview
    hrSurfaceMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, titleHeightRatio]
    @add(hrSurfaceMod).add(hrSurface)


    for title, i in ['Insights', 'Activities', 'Lorem Ip']
      titleSurface = new Surface
        size: [undefined, true]
        content: title
        properties:
          color: 'white'
          fontSize: '26pt'
          textTransform: 'uppercase'
      titleContainer = new ContainerSurface
        size: [@titleWidth, @titleHeight]
        # proportions: [titleWidthRatio, titleHeightRatio]
      titleMod = new StateModifier
        origin: [0.0, 1.0]
        align: [0.0, 0.93]
        transform: Transform.translate marginX * @bodyWidth, null, 2
      titleSurface.pipe @titlesScrollview
      titleContainer.pipe @titlesScrollview
      titleContainer.add(titleMod).add(titleSurface)
      titleContainer.titleSurface = titleSurface
      titleContainer.titleMod = titleMod
      page = @_titlesScrollviewItems.length
      titleContainer.on 'click', do (page) => =>
        console.log page
        @titlesScrollview.goToPage(page)
      @_titlesScrollviewItems.push titleContainer

    ## SECTIONS ##

    ## --> Activity ##
    _activityScrollviewItems = []
    activityScrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: true
    activityScrollviewMod = new StateModifier
      size: [@bodyWidth, @bodyHeight]
      # proportions: [1, bodyHeightRatio]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
    activityScrollview.sequenceFrom _activityScrollviewItems
    activityRenderNode = new RenderNode().add(activityScrollviewMod).add(activityScrollview)

    for i in [1..3]
      surface = new Surface
        size: [@bodyWidth, @bodyHeight]
        # proportions: [1, bodyHeightRatio]
        content: "Activity ##{i}"
        properties:
          textAlign: 'center'
          color: 'white'
          fontSize: '20pt'
          textTransform: 'uppercase'
          paddingTop: '2em'
      surface.pipe activityScrollview
      _activityScrollviewItems.push surface

    ## --> Insights ##
    insightsView = new InsightsView()

    ## --> Sections ##
    sections = [
      { title: 'Who knows me the best?', renderable: insightsView }
      { title: 'Activities View', renderable: activityRenderNode }
      { title: 'Lorem Ipsum View', renderable: null }
      # { title: 'blah blah', renderable: null }
    ]
    @sectionsContainer = new ContainerSurface
      size: [@bodyWidth * sections.length, @bodyHeight]
      # proportions: [sections.length, bodyHeightRatio]
      properties:
        overflow: 'hidden'
    @sectionsContainerMod = new StateModifier
      align: [0.0, 0.0]
      origin: [0.0, 0.0]
      transform: Transform.translate 0, @titleHeight, 0
    @add(@sectionsContainerMod).add @sectionsContainer

    @sectionsContainer.pipe @titlesScrollview
    insightsView.on 'start', =>
      @sectionsContainer.unpipe @titlesScrollview
    insightsView.on 'end', =>
      @sectionsContainer.pipe @titlesScrollview

    for view, i in sections
      mod = new StateModifier
        origin: [0, 0]
        align: [i/sections.length, 0]
      if view.renderable?
        @sectionsContainer.add(mod).add view.renderable
      else
        surface = new Surface
          size: [@bodyWidth, @bodyHeight]
          # proportions: [1, bodyHeightRatio]
          content: view.title
          properties:
            textAlign: 'center'
            color: 'white'
            fontSize: '20pt'
            textTransform: 'uppercase'
            paddingTop: '2em'
        @sectionsContainer.add(mod).add surface

    ## ACTIVITY ##
    # _sectionsScrollviewItems: []
    # @activityView = new ActivityView
    # @_sectionsScrollviewItems.push @activityView
    # @activityView.pipe @titlesScrollview

  initGestures: ->
    # @titlesScrollview.sync.on 'end', =>
    #   console.log @

    minOpacity = 0.5
    maxDistance = halfWidth = @titleWidth / 2

    update = =>
      absPosition = @titlesScrollview.getAbsolutePosition()

      # slide the sections container left/right
      sectionsXTranslation = -absPosition / @ratio
      @sectionsContainerMod.setTransform Transform.translate sectionsXTranslation, @titleHeight, 0

      # animate the title opacity
      numItems = @_titlesScrollviewItems.length
      for item, i in @_titlesScrollviewItems
        midpoint = @titleWidth * ( i + 1 / 2 )
        distanceFromMidpoint = Math.abs(absPosition + halfWidth - midpoint)
        distanceRatio = Math.min(maxDistance, distanceFromMidpoint) / maxDistance
        opacity = 1 - distanceRatio + minOpacity
        @_titlesScrollviewItems[i].titleMod.setOpacity opacity

    @titlesScrollview.sync.on 'update', update
    @titlesScrollview._particle.on 'update', update

module.exports = WeView
