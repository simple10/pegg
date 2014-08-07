
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Utils = require 'lib/Utils'

class PeggStatusItemView extends View

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [Utils.getViewportWidth(), 70]
      properties:
        overflow: 'hidden'
    @peggerPic = new ImageSurface
      classes: ['status__pegger__pic']
      size: [50, 50]
      properties:
        borderRadius: '50px'
    peggerPicMod = new StateModifier
      align: [0.1, 0]
      origin: [0, 0]
    container.add(peggerPicMod).add @peggerPic
#    unicornPic = new ImageSurface
#      classes: ['status__unicorn__pic']
#      size: [50, 50]
#    unicornPicMod = new StateModifier
#      align: [0.2, 0]
#      origin: [0, 0]
#    container.add(unicornPicMod).add unicornPic
    @peggerName = new Surface
      classes: ['status__pegger__name']
      size: [Utils.getViewportWidth(), 30]
    peggerNameMod = new StateModifier
      align: [0.3, 0.1]
      origin: [0, 0]
    container.add(peggerNameMod).add @peggerName
    @points = new Surface
      classes: ['status__pegger__points']
      size: [Utils.getViewportWidth(), 30]
    pointsMod = new StateModifier
      align: [0.3, 0.34]
      origin: [0, 0]
    container.add(pointsMod).add @points
    @add container

  load: (data) =>
    if data?
      pegger = data.pegger
      @peggerPic.setContent "#{pegger.get 'avatar_url'}?height=50&type=normal&width=50"
      @peggerName.setContent "#{pegger.get 'first_name'} #{pegger.get 'last_name'}"
      @points.setContent "#{data.points} points"



module.exports = PeggStatusItemView
