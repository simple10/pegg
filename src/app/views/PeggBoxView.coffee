require './peggbox'

View = require 'famous/core/View'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
RenderNode = require 'famous/core/RenderNode'
StateModifier = require 'famous/modifiers/StateModifier'

class PeggBoxView extends View
  @DEFAULT_OPTIONS:
    model: null

  constructor: (options) ->
    #options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @init()

  init: ->
    @items = @options.model
    @build()

  build: ->

    surfaces = []
    scrollview = new Scrollview
    scrollview.sequenceFrom surfaces

    i = 0
    while i < @items.length
      pic = @items[i].pic
      message = @items[i].message
      content = "
        <h2><img src='#{pic}' />#{message}</h2>
      "

      node = new RenderNode

      item = new Surface
        size: [undefined, 50]
        content: content
        classes: ['question']

      modifier = new StateModifier
        origin: [0, 0]
        align: [0.25, 0]

      node.add(modifier).add item

      item.pipe scrollview
      surfaces.push node
      i++

    container = new ContainerSurface
      size: [null, null]
      properties:
        overflow: "hidden"

    container.add scrollview
    @add scrollview



module.exports = PeggBoxView
