View = require 'famous/core/View'
RenderNode = require 'famous/core/RenderNode'
Surface = require 'famous/core/Surface'
Scrollview = require 'famous/views/Scrollview'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Utility = require 'famous/utilities/Utility'
Transform = require 'famous/core/Transform'
SequentialLayout = require 'famous/views/SequentialLayout'

Utils = require 'lib/Utils'
PrefBoardRowView = require 'views/PrefBoardRowView'

class PrefBoardView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight()
    columns: 3
    gutter: 5
    headerHeight: 30

  constructor: (options) ->
    super options

    # Update width with gutter size taken into account
    @setOptions
      width: @options.width - @options.gutter
      height: @options.height - @options.gutter

    @init()

  init: () ->
    @initHeader()

    @containerMod = new StateModifier
      transform: Transform.translate(0, @options.headerHeight, 0)
    @container = new ContainerSurface
      size: [@options.width, @options.height]
      classes: ['peggBoard']
      properties: {
        overflow: 'hidden'
      }

    @scrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 500

    @container.add @scrollview
    @add(@containerMod).add @container

  initHeader: () ->
    @buttons = []

    headerBacking = new Surface
      size: [undefined, @options.headerHeight]
      classes: ['peggBoardHeader', 'peggBoardHeader__bg']

    @_addHeaderButton('one')
    @_addHeaderButton('two')
    @_addHeaderButton('three')

    sequence = new SequentialLayout
      direction: Utility.Direction.X

    sequence.sequenceFrom @buttons

    @add headerBacking
    @add sequence


  _addHeaderButton: (content, clickCallback, numOfButtons) ->
    content = content || ''
    clickCallback = clickCallback || () ->
      console.log @
    numOfButtons = numOfButtons || 3

    itemWidth = Utils.getViewportWidth() / numOfButtons
    itemHeight = @options.headerHeight

    surface = new Surface
      content: content
      size: [itemWidth, itemHeight]
      classes: ['peggBoardHeader', 'peggBoardHeader__button']
      properties: {
        textAlign: 'center'
        lineHeight: itemHeight + 'px'
      }

    surface.on 'click', clickCallback

    @buttons.push surface


  loadImages: (data) ->
    # TODO will need to figure out some way of reusing current surfaces
    @rows = []
    @scrollview.sequenceFrom @rows

    ## Initialize Rows
    while data.length
      set = data.splice 0, @options.columns
      row = new PrefBoardRowView
        width: @options.width
        height: @options.height
        columns: @options.columns
        gutter: @options.gutter
        data: set

      # row.pipe @scrollview
      @rows.push row

    @pipeToScrollview()

  pipeToParent: ->
    for row in @rows
      row.unpipe @scrollview
      row.pipe @_eventOutput

    @container.unpipe @scrollview
    @container.pipe @_eventOutput
    

  pipeToScrollview: ->  
    for row in @rows
      row.unpipe @_eventOutput
      row.pipe @scrollview

    @container.unpipe @_eventOutput
    @container.pipe @scrollview


module.exports = PrefBoardView
