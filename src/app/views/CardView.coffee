# CardView
#
# Flip between front and back side of card.

require './card.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
StateModifer = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'
_ = require('Parse')._

class CardView extends View
  @DEFAULT_OPTIONS:
    width: 290
    height: 350
    depth: 8
    borderRadius: 10
    duration: 1500
    easing: Easing.outCubic

  constructor: (card, options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @init(card)

  init: (card) ->
    width = @options.width
    height = @options.height
    depth = @options.depth

    @state = new StateModifer
    @mainNode = @add @state

    question = card.get "title"
    image = card.get "image1"
    answer = card.get "caption1"

    options = '<p>' + card.get("caption1") + '</p>'
    options += '<p>' + card.get("caption2") + '</p>'
    options += '<p>' + card.get("caption3") + '</p>'

    # Front
    @addSurface
      size: [ width, height ]
      content: "<h2>#{question}</h2>#{options}"
      classes: ['card__front']
      properties:
        borderRadius: "#{@options.borderRadius}px"
      transform: Transform.translate 0, 0, depth/2
    # Front Backing
    @addSurface
      size: [ width, height ]
      classes: ['card__backing']
      properties:
        borderRadius: "#{@options.borderRadius}px"
      transform: Transform.multiply(
        Transform.translate 0, 0, depth/2-1
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    # Back
    @addSurface
      size: [ width, height ]
      content: "<img width='#{width-50}' src='#{image}'/><h3>#{answer}</h3>"
      classes: ['card__back']
      properties:
        borderRadius: "#{@options.borderRadius}px"
        padding: "10px"
      transform: Transform.multiply(
        Transform.translate(0, 0, -depth/2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    # Back Backing
    @addSurface
      size: [ width, height ]
      classes: ['card__backing']
      properties:
        borderRadius: "#{@options.borderRadius}px"
      transform: Transform.translate 0, 0, -depth/2+1


  addSurface: (params) ->
    surface = new Surface
      size: params.size
      content: params.content
      classes: params.classes
      properties: params.properties
    modifier = new Modifier
      transform: params.transform
    surface.on 'click', @flip
    surface.pipe @_eventOutput
    @mainNode.add(modifier).add surface

  flip: (side) =>
    @state.halt()
    @currentSide ?= 0
    if side is 0 or side is 1
      @currentSide = side
    else
      @currentSide = if @currentSide is 1 then 0 else 1

    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      duration : @options.duration
      curve: @options.easing
    )


module.exports = CardView


