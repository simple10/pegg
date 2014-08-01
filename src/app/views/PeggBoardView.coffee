View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Scrollview = require 'famous/views/Scrollview'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
StateModifier = require 'famous/modifiers/StateModifier'

Utils = require 'lib/Utils'
PeggBoardRowView = require 'views/PeggBoardRowView'

class PeggBoardView extends View
  @DEFAULT_OPTIONS:
    width: undefined
    height: 250

  constructor: (options) ->
    super options

    @init()

  init: () ->
    @rows = []
    @container = new ContainerSurface
      size: [@options.width, @options.height]
      classes: ['peggBoard']
      properties: {
        overflow: 'hidden'
      }
    @scrollview = new Scrollview

    peggs = @getPeggs()

    ## Initialize Rows
    # while peggs.length
    #   set = peggs.splice(0,4)
    #   row = new PeggBoardRowView
    #     data: set
    #   @rows.push row

    # TODO This doesn't work... why???

    for i in peggs
      surface = new Surface
        content: i
        size: [undefined, 100]
        properties: {
           backgroundColor: 'hsl(' + (i * 360 / 40) + ', 100%, 50%)'
           lineHeight: '100px'
           textAlign: 'center'
         }
      @rows.push(surface)

    console.log @rows.length

    @scrollview.sequenceFrom(@rows)
    @add(@container).add(@scrollview)
    

  getPeggs: () ->
    # TODO implement this
    return [1..20]

module.exports = PeggBoardView