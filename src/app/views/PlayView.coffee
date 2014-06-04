require './play.scss'

View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
CardView = require 'views/CardView'

class PlayView extends View

  constructor: () ->
    super
    @init()


  init: ->
    @cards = []
    @load([
      {id: 1, question: "What's the meaning of life?", answer: "42"}
      {id: 2, question: "What's lies in the middle of meaning?", answer: "3"}
    ])


  load: (set) ->
    @cards = set

    surfaces = []
    scrollview = new Scrollview
    scrollview.sequenceFrom surfaces

    i = 0
    while i < @cards.length
      card = new CardView
        question: @cards[i].question
        answer: @cards[i].answer

      card.pipe scrollview
      surfaces.push card
      i++

    @add scrollview



module.exports = PlayView
