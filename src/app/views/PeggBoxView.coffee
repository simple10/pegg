require './peggbox.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'

ListItemView = require 'views/ListItemView'

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
      item = new ListItemView @items[i]
      item.pipe scrollview
      surfaces.push item
      i++

    container = new ContainerSurface
      size: [undefined, undefined]
      properties:
        overflow: "hidden"


    container.add scrollview
    @add container



module.exports = PeggBoxView
