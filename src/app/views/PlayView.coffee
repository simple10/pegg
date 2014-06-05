require './play.scss'

View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
CardView = require 'views/CardView'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'

class PlayView extends View

  constructor: () ->
    super
    @initCards()

  initCards: ->
    @cards = []

  load: (data) ->
    @cards = data

    surfaces = []
    scrollview = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 10000
    scrollview.sequenceFrom surfaces

    i = 0
    while i < @cards.length
      card = new CardView(@cards[i], size: [350, null])
      card.pipe scrollview
      surfaces.push card
      i++


    #node.add(modifier).add scrollview
    #@add node

    @add scrollview



module.exports = PlayView
