###
3D Rotating Card
----------
You can define a rotation as the (noncommutative) multiplication
of two Quaternions. When you do this, the first quaternion has
the rotation described by the second quaternion added to it.

In this example, we have two quaternions, one that defines the box's
current rotation, and another which defines a rotation to be added
to the box.
###

Engine = require("famous/core/Engine")
Surface = require("famous/core/Surface")
Modifier = require("famous/core/Modifier")
Transform = require("famous/core/Transform")
RenderNode = require("famous/core/RenderNode")
Quaternion = require("famous/math/Quaternion")

mainContext = Engine.createContext()

# The axis of the rotation is a Left Hand Rule vector with X Y Z (i j k) components
quaternion = new Quaternion(1, 0, 0, 0)
smallQuaternion = new Quaternion(200, 1, 4, 1)

# Bind the box's rotation to the quaternion
rotationModifier = new Modifier(origin: [ 0.5, 0.5 ])
borderRadius = 30
rotationModifier.transformFrom ->
  quaternion.getTransform()

mainContext.add(rotationModifier).add createBox(200, 300, 10)
mainContext.setPerspective 400

# This is where the rotation is created
Engine.on "prerender", ->
  # Combine rotations through quaternion multiplication
  quaternion = quaternion.multiply(smallQuaternion)

Engine.on "click", ->
  x = (Math.random() * 20) - 1
  y = (Math.random() * 20) - 1
  z = (Math.random() * 20) - 1
  smallQuaternion = new Quaternion(200, x, y, z)


createSide = (params) ->
  surface = new Surface(
    size: params.size
    content: params.content
    classes: params.classes
    properties: params.properties
  )
  modifier = new Modifier(transform: params.transform)
  box.add(modifier).add surface


# Creates box renderable
createBox = (width, height, depth) ->
  box = new RenderNode()

  # Front
  createSide
    size: [ width, height ]
    content: "<h2>Hello World, let's get friendly.</h2>"
    classes: [ "red-bg" ]
    properties:
      lineHeight: 25 + "px"
      textSize: "20px"
      textAlign: "center"
      overflow: "auto"
      borderRadius: borderRadius + "px"
    transform: Transform.translate(0, 0, depth / 2)

  # Middle
  # This is a two sided card that sits in the middle of the front and back.
  # Using this middle card gives the illusion of depth without seeing through to the content of the other side.
  createSide
    size: [ width, height ]
    content: ""
    classes: [ "backface-visible" ]
    properties:
      backgroundColor: "black"
      overflow: "auto"
      borderRadius: borderRadius + "px"
    transform: Transform.multiply(Transform.translate(0, 0, -depth / 2), Transform.multiply(Transform.rotateZ(Math.PI), Transform.rotateX(Math.PI)))

  # Back
  createSide
    size: [ width, height ]
    content: "G'bye world, Good to know you :D"
    properties:
      lineHeight: height + "px"
      textAlign: "center"
      backgroundColor: "#ccc"
      fontSize: "18px"
      overflow: "hidden"
      color: "#777"
      borderRadius: borderRadius + "px"
    transform: Transform.multiply(Transform.translate(0, 0, -depth), Transform.multiply(Transform.rotateZ(Math.PI), Transform.rotateX(Math.PI)))

  # // Back Back
  # createSide({
  #     size: [width, height],
  #     content: '',
  #     classes: ['backface-visible'],
  #     properties: {
  #         lineHeight: height + 'px',
  #         textAlign: 'center',
  #         backgroundColor: 'black',
  #         fontSize: '18px',
  #         overflow: 'hidden',
  #         color: '#777',
  #         borderRadius: borderRadius + 'px'
  #     },
  #     transform: Transform.translate(0, 0, depth / 2 - 1)
  #     // transform: Transform.multiply(Transform.translate(0, 0, - depth / 2 + 2), Transform.multiply(Transform.rotateZ(Math.PI), Transform.rotateX(Math.PI))),
  # });

  # // Top
  # createSide({
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
  # createSide({
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
  # createSide({
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
  # createSide({
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
  box
