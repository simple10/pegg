# Famo.us
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
RenderController = require 'famous/src/views/RenderController'
RenderNode = require 'famous/src/core/RenderNode'
Scrollview = require 'famous/src/views/Scrollview'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Transform = require 'famous/src/core/Transform'
Transitionable  = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
Utils = require 'lib/Utils'
ActivityView = require 'views/ActivityView'
InsightsView = require 'views/InsightsView'

class WeView extends View

  constructor: (options) ->
    super options
    @initRenderables()
    @initGestures()

  initRenderables: ->
    @titleWidth  = Utils.getViewportWidth() * 4 / 5
    @titleHeight = Utils.getViewportHeight() / 6
    @bodyWidth   = Utils.getViewportWidth()
    @bodyHeight  = Utils.getViewportHeight() * 5 / 6
    @ratio = @titleWidth / @bodyWidth

    ## TITLES ##
    _titlesScrollviewItems = []
    @titlesScrollview = new Scrollview
      direction: Utility.Direction.X
      paginated: true
    @titlesScrollview.sequenceFrom _titlesScrollviewItems
    titlesScrollviewMod = new StateModifier
      size: [@titleWidth, @titleHeight]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
      transform: Transform.translate null, null, 2
    @add(titlesScrollviewMod).add @titlesScrollview

    titlesBackground = new Surface
    titlesBackground.pipe @titlesScrollview
    titlesBackgroundMod = new StateModifier
      size: [@bodyWidth, @titleHeight]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
      transform: Transform.translate null, null, 3
    @add(titlesBackgroundMod).add titlesBackground

    for title in ['Insights', 'Activities']
      titleSurface = new Surface
        size: [undefined, true]
        content: title
        properties:
          color: 'white'
          fontSize: '26pt'
          textTransform: 'uppercase'
      titleContainer = new ContainerSurface
        size: [@titleWidth, @titleHeight]
      titleMod = new StateModifier
        origin: [0.0, 1.0]
        align: [0.0, 1.0]
      # titleSurface.mod = titleMod
      titleSurface.pipe @titlesScrollview
      titleContainer.add(titleMod).add(titleSurface)
      _titlesScrollviewItems.push titleContainer

    ## INSIGHTS ##
    _activityScrollviewItems = []
    activityScrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: true
    activityScrollviewMod = new StateModifier
      size: [@bodyWidth, @bodyHeight]
      origin: [0.0, 0.0]
      align: [0.0, 0.0]
    activityScrollview.sequenceFrom _activityScrollviewItems
    activityRenderNode = new RenderNode().add(activityScrollviewMod).add(activityScrollview)

    for i in [1..3]
      surface = new Surface
        size: [@bodyWidth, @bodyHeight]
        content: "Activity ##{i}"
        properties:
          textAlign: 'center'
          color: 'white'
          fontSize: '20pt'
          textTransform: 'uppercase'
          paddingTop: '2em'
      surface.pipe activityScrollview
      _activityScrollviewItems.push surface


    insightsView = new InsightsView()

    ## SECTIONS ##
    sections = [
      { title: 'Who knows me the best?', renderable: insightsView }
      { title: 'Activities View', renderable: activityRenderNode }
      # { title: 'Lorem Ipsum View', renderable: null }
      # { title: 'blah blah', renderable: null }
    ]
    @sectionsContainer = new ContainerSurface
      size: [@bodyWidth * sections.length, @bodyHeight]
      properties:
        overflow: 'hidden'
    @sectionsContainerMod = new StateModifier
      align: [0.0, 0.0]
      origin: [0.0, 0.0]
      transform: Transform.translate 0, @titleHeight, 0
    @add(@sectionsContainerMod).add @sectionsContainer
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

    update = =>
      translation = -@titlesScrollview.getAbsolutePosition() / @ratio
      @sectionsContainerMod.setTransform Transform.translate translation, @titleHeight, 0

    @titlesScrollview.sync.on 'update', update

    @titlesScrollview._particle.on 'update', update

    #   offset = @titlesScrollview._scroller.getCumulativeSize(@titlesScrollview.getCurrentIndex())[0]
    #   position = @titlesScrollview._particle.getPosition1D()
    #   console.log offset, position
    #   @sectionsScrollview._particle.setPosition1D offset + position

    # @titlesScrollview.on 'settle', =>
    #   page = @titlesScrollview.getCurrentIndex()
    #   # console.log "going to page: ", page
    #   @sectionsScrollview.goToNextPage()

    # @titlesScrollview._eventOutput.on 'pageChange', (payload) =>
    #   console.log "page change", payload
    #   if payload.direction is -1
    #     @sectionsScrollview.goToPreviousPage()
    #   else if payload.direction is 1
    #     @sectionsScrollview.goToNextPage()

module.exports = WeView
