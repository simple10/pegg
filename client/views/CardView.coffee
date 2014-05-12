# CardView
#
# Flip between front and back side of card.

require 'styles/card'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Transitionable = require 'famous/transitions/Transitionable'
Utility = require 'famous/utilities/Utility'


class CardView extends View
  @DEFAULT_OPTIONS:
    width: 200
    height: 300
    depth: 10
    flip:
      direction: Utility.Direction.Y
      transition: true

  constructor: ->
    super
    @init()

  init: ->
    width = @options.width
    height = @options.height
    depth = @options.depth

    @state = new Transitionable 0


    # Front
    @addSurface
      size: [ width, height ]
      content: "<h2>Front of card.</h2>"
      classes: ['card__front']
      transform: Transform.translate(0, 0, depth / 2)

    # Middle
    # This is a two sided card that sits in the middle of the front and back.
    # Using this middle card gives the illusion of depth without seeing through to the content of the other side.
    @addSurface
      size: [ width, height ]
      classes: ['card__middle']
      transform: Transform.translate(0, 0, -depth / 2)

    # Back
    @addSurface
      size: [ width, height ]
      content: "<h3>Back of card</h3>"
      classes: ['card__back']
      transform: Transform.multiply(
        Transform.translate(0, 0, -depth)
        Transform.multiply(
          Transform.rotateZ(Math.PI)
          Transform.rotateX(Math.PI)
        )
      )

  addSurface: (params) ->
    surface = new Surface
      size: params.size
      content: params.content
      classes: params.classes
      properties: params.properties
    modifier = new Modifier
      transform: params.transform
    surface.on 'click', @flip
    @add(modifier).add surface

  flip: (side) =>
    @currentSide ?= 0
    if side is 0 or side is 1
      @currentSide = side
    else
      @currentSide = if @currentSide is 1 then 0 else 1
    @state.set @currentSide, @options.flip.transition

  render: ->
    pos = @state.get()
    axis = @options.flip.direction
    rotation = [0, 0, 0]
    rotation[axis] = Math.PI * pos
    [
      transform: Transform.rotate.apply null, rotation
      target: @_node.render()
    ]

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
