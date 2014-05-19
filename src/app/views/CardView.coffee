# CardView
#
# Flip between front and back side of card.

require 'css/card'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
StateModifer = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'

class CardView extends View
  @DEFAULT_OPTIONS:
    width: 400
    height: 600
    depth: 100
    borderRadius: 30
    duration: 10500
    easing: Easing.outElastic

  constructor: ->
    super
    @init()

  init: ->
    width = @options.width
    height = @options.height
    depth = @options.depth

    @state = new StateModifer
    @mainNode = @add @state

    # Front
    @addSurface
      size: [ width, height ]
      content: "<h2>Front of card.</h2>"
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
    # Shim left
    @addSurface
      size: [depth-2, height]
      classes: ['card__left']
      content: 'Left'
      transform: Transform.multiply(
        Transform.translate -width/2+@options.borderRadius, 0, 1
        Transform.rotateY -Math.PI/2
      )
    # Shim right
    @addSurface
      size: [depth-2, height]
      classes: ['card__right']
      content: 'Right'
      transform: Transform.multiply(
        Transform.translate width/2-@options.borderRadius, 0, 1
        Transform.rotateY Math.PI/2
      )
    # Back
    @addSurface
      size: [ width, height ]
      content: "<h3>Back of card</h3>"
      classes: ['card__back']
      properties:
        borderRadius: "#{@options.borderRadius}px"
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



#
# FOR REFERENCE ON HOW TO ADD SIDES
#

# // Top
# addSurface({
#     size: [width - borderRadius*2, depth],
#     content: 'I\'m on Top! Just a shimmy and a shake',
#     properties: {
#         lineHeight: depth + 'px',
#         textAlign: 'center',
#         backgroundColor: '#0cf',
#         overflow: 'hidden',
#         color: '#666'
#     },
#     transform: Transform.multiply(Transform.translate(0, -height / 2, 0), Transform.rotateX(Math.PI/2)),
# });

# // Bottom
# addSurface({
#     size: [width - borderRadius*2, depth],
#     content: 'I\'m the bottom!',
#     properties: {
#         lineHeight: depth + 'px',
#         textAlign: 'center',
#         backgroundColor: '#fc0',
#         overflow: 'hidden',
#         color: '#777'
#     },
#     transform: Transform.multiply(Transform.translate(0, height / 2, 0), Transform.multiply(Transform.rotateX(-Math.PI/2), Transform.rotateZ(Math.PI))),
# });

# // Left
# addSurface({
#     size: [depth, height - borderRadius*2],
#     content: 'I\'m the Left! I\'m content',
#     properties: {
#         lineHeight: height + 'px',
#         textAlign: 'center',
#         backgroundColor: '#f0c',
#         overflow: 'hidden',
#         color: '#777'
#     },
#     transform: Transform.multiply(Transform.translate(-width / 2, 0, 0), Transform.rotateY(-Math.PI/2))
# });

# // Right
# addSurface({
#     size: [depth, height - borderRadius*2],
#     content: 'I\'m always Right!',
#     properties: {
#         lineHeight: height + 'px',
#         textAlign: 'center',
#         backgroundColor: '#c0f',
#         overflow: 'hidden',
#         color: '#777'
#     },
#     transform: Transform.multiply(Transform.translate(width / 2, 0, 0), Transform.rotateY(Math.PI/2))
# });
