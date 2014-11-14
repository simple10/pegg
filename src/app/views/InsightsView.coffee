require './scss/status.scss'
_ = require('Parse')._

# Famo.us
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Modifier = require 'famous/src/core/Modifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Utility = require 'famous/src/utilities/Utility'
Scrollview = require 'famous/src/views/Scrollview'
Utils = require 'lib/Utils'
RenderNode = require 'famous/src/core/RenderNode'
Vector = require "famous/src/math/Vector"
ImageSurface = require "famous/src/surfaces/ImageSurface"
PhysicsEngine = require "famous/src/physics/PhysicsEngine"
Walls = require "famous/src/physics/constraints/Walls"
Circle = require "famous/src/physics/bodies/Circle"
Body = require "famous/src/physics/bodies/Body"
Repulsion = require "famous/src/physics/forces/Repulsion"

# Pegg
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
WeStore = require 'stores/WeStore'

class InsightsView extends View

  constructor: (options) ->
    super options

    @physics = new PhysicsEngine()

    @initListeners()
    @initRenderables()
    @initGravity()

  initListeners: ->
    WeStore.on Constants.stores.INSIGHTS_LOADED, @load

  initRenderables: ->
    @container = new ContainerSurface
      size: [Utils.getViewportWidth(), undefined]
    containerMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
    @add(containerMod).add @container

  initGravity: ->
    @well = new Body
      mass: 10
      position: [0, 0, 0]
#      position: [Utils.getViewportWidth()/2, Utils.getViewportHeight()/2, 0]
    @gravity = new Repulsion
      strength: -100
      decayFunction: Repulsion.DECAY_FUNCTIONS.LINEAR

    @container.add @well
    @physics.addBody @well

  createBall: (image) ->
    circle = new Circle(radius: 25)
    surface = new ImageSurface
      size: [50, 50]
      content: image
      properties:
        borderRadius: '25px'

    modifier = new Modifier
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      transform: ->
        circle.getTransform()

    circle: circle
    modifier: modifier
    surface: surface

  createWalls: ->
    # A wall with no options set assumes you want four walls,
    # one for each of the screen edges.
    new Walls {}

  load: =>
    console.log 'InsightsView.load...'

    insights = WeStore.getInsights()
    if insights?

      balls = []
      circles = []

      walls = @createWalls()
      walls.options.sides = walls.components     # Patch for bug in Walls module.
      walls.sides = walls.components             # Patch for bug in Walls module.
      walls.options.restitution = 0.1

      for insight in insights
        ball = @createBall insight.pegger.get('avatar_url')
        balls.push ball
        circles.push ball.circle
        @container.add(ball.modifier).add ball.surface
        @physics.addBody ball.circle

      for ball in balls
        repulsion = new Repulsion
          strength: 0.0005
        @physics.attach walls, ball.circle
        @physics.attach @gravity, ball.circle, @well
        @physics.attach repulsion, circles, ball.circle
        ball.circle.applyForce new Vector(Math.random() * 0.0005, Math.random() * 0.0005, 0)


module.exports = InsightsView
