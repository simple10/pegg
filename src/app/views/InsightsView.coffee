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
Drag = require "famous/src/physics/forces/Drag"
Spring = require "famous/src/physics/forces/Spring"
GenericSync = require 'famous/src/inputs/GenericSync'
MouseSync = require 'famous/src/inputs/MouseSync'
TouchSync = require 'famous/src/inputs/TouchSync'

# Pegg
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
WeStore = require 'stores/WeStore'

class InsightsView extends View

  constructor: (options) ->
    super options

    @physics = new PhysicsEngine()

    @initEvents()
    @initListeners()
    @initRenderables()
    @initGravity()
    console.log "InsightsView constructed"

  initEvents: ->
    GenericSync.register 'mouse': MouseSync, 'touch': TouchSync

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
      mass: 100
      position: [0, 0, 0]
     # position: [Utils.getViewportWidth()/2, Utils.getViewportHeight()/2, 0]
    @gravity = new Repulsion
      strength: -100
      # decayFunction: Repulsion.DECAY_FUNCTIONS.INVERSE

    @container.add @well
    @physics.addBody @well

  createBall: (image, size) ->
    size = size % 50 + 50
    circle = new Circle(radius: size)
    surface = new ImageSurface
      size: [size, size]
      content: image
      properties:
        borderRadius: "#{size}px"

    modifier = new Modifier
      align: [Math.random() * 0.5 + 0.25, Math.random() * 0.5 + 0.25]
      origin: [0.5, 0.5]
      transform: ->
        circle.getTransform()

    sync = new GenericSync ['mouse', 'touch']
    surface.pipe sync

    sync.on 'start', (data) =>
      @_eventOutput.emit 'start'

    sync.on 'update', (data) =>
      circle.position.x += data.delta[0]
      circle.position.y += data.delta[1]

    sync.on 'end', (data) =>
      @_eventOutput.emit 'end'

    circle: circle
    modifier: modifier
    surface: surface
    sync: sync

  createWalls: ->
    # A wall with no options set assumes you want four walls,
    # one for each of the screen edges.
    new Walls
      restitution: [0.001, 0.001, 0.001, 0.001]
      slop: [0, 0, 0, 0]

  load: =>
    console.log 'InsightsView.load...'

    insights = WeStore.getInsights()
    if insights?
      balls = []
      circles = []

      walls = @createWalls()
      walls.options.sides = walls.components     # Patch for bug in Walls module.
      walls.sides = walls.components             # Patch for bug in Walls module.

      for insight in insights
        ball = @createBall insight.pegger.get('avatar_url'), insight.points
        balls.push ball
        circles.push ball.circle
        @container.add(ball.modifier).add ball.surface
        @physics.addBody ball.circle
        @physics.attach walls, ball.circle
        # @physics.attach @gravity, ball.circle, @well

      for ball in balls
        repulsion = new Repulsion strength: -0.0005
        spring = new Spring
          anchor: @well
          strength: 10,
          dampingRatio: 0.4,
          # forceFunction: Spring.FORCE_FUNCTIONS.FENE,
          length: 100
        drag = new Drag strength: 0.0001, forceFunction: Drag.FORCE_FUNCTIONS.QUADRATIC
        friction = new Drag strength: 0.01, forceFunction: Drag.FORCE_FUNCTIONS.LINEAR
#        @physics.attach repulsion, circles, ball.circle
        # @physics.attach [drag, friction], ball.circle
        # @physics.attach friction, ball.circle
        # @physics.attach drag, ball.circle
#        @physics.attach spring, circles, ball.circle
        ball.circle.applyForce new Vector(Math.random() * 0.0005, Math.random() * 0.0005, 0)
        # ball.circle.applyForce new Vector(0, 0, 0)

module.exports = InsightsView
