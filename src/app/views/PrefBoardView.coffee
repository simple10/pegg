View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Scrollview = require 'famous/views/Scrollview'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Utility = require 'famous/utilities/Utility'

Utils = require 'lib/Utils'
PrefBoardRowView = require 'views/PrefBoardRowView'

class PrefBoardView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight()
    columns: 3
    gutter: 5

  constructor: (options) ->
    super options

    # Update width with gutter size taken into account
    @setOptions
      width: @options.width - @options.gutter
      height: @options.height - @options.gutter

    @init()

  init: () ->
    @container = new ContainerSurface
      size: [@options.width, @options.height]
      classes: ['peggBoard']
      properties: {
        overflow: 'hidden'
      }

    @scrollviewMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
    @scrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 500

    @container.add @scrollview
    @container.pipe @scrollview
    @add(@container)

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

      row.pipe @scrollview
      @rows.push row



module.exports = PrefBoardView
