require './scss/card.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
Surface = require 'famous/core/Surface'
ListItemView = require 'views/ListItemView'

class ChoicesView extends View
  @DEFAULT_OPTIONS:
    itemDensity: null
    width: window.innerHeight/2
    height: 60


  constructor: () ->
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
      #item = new ListItemView @items[i]
      @items[i].on 'scroll', =>
        @_eventOutput.emit 'scroll'
      @items[i].pipe scrollview
      surfaces.push @items[i]
      i++

    newChoice = new Surface
      size: [ @options.width, @options.height ]
      content: "<input type='text' name='newOption' class='card__front_newOption' placeholder='Type your own...'>"

    surfaces.push newChoice

    container = new ContainerSurface
      size: [window.innerHeight/2, 260]
      properties:
        overflow: "hidden"

    container.add scrollview
    @add container



module.exports = ChoicesView
