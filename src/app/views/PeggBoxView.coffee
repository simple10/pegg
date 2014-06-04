require './peggbox.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'

ListItemView = require 'views/ListItemView'

class PeggBoxView extends View
  @DEFAULT_OPTIONS:
    itemDensity: null

  constructor: (options) ->
    super
    @init()

  init: ->
    @items = []

  load: (data) ->

    @items = data

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
