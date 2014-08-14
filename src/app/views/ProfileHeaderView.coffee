View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'

Utils = require 'lib/Utils'

class ProfileHeaderView extends View

  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth()
    height: 200
    avatar: ''
    firstname: ''

  constructor: (options) ->
    super options

    @init()

  init: ->
    @mainMod = new StateModifier
      origin: [0,0]
      align: [0,0]
      size: [@options.width, @options.height]

    @picContainer = new ContainerSurface
      size: [@options.width, @options.height]
      classes: ['profilePic']
      properties:
        overflow: 'hidden'
    
    @pic = new ImageSurface
      size: [ @options.width, @options.width]
      content: @options.avatar
      classes: ['profile__pic']
    picMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    
    @name = new Surface
      size: [270, 35]
      classes: ['profile__name__box']
      content: "#{@options.firstname}'s <strong>profile</strong>"
    nameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 1]

    node = @add @mainMod
    @picContainer.add @pic
    node.add(picMod).add @picContainer
    node.add(nameMod).add @name

    nameMod.setTransform Transform.translate(0, 160, 0), {duration: 500, easing: Easing.outCubic}

  setAvatar: (url) ->
    @setOptions({
      avatar: url
    })
    @pic.setContent url

  setFirstname: (name) ->
    @setOptions({
      firstname: name
    })
    @name.setContent "#{@options.firstname}'s <strong>profile</strong>"

module.exports = ProfileHeaderView