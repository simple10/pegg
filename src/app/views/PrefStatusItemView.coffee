
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

class PrefStatusItemView extends View

  container = null

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [window.innerWidth, 70]
      properties:
        overflow: 'hidden'

    # Question
    @question = new Surface
      classes: ['status__pref__question']
      size: [50, 50]
      properties:
        borderRadius: '50px'
    questionMod = new StateModifier
      align: [0.1, 0]
      origin: [0, 0]
    container.add(questionMod).add @question

    # Answer choice x 4
    @_addChoice()
    # percent chosen
    # color bar

    @peggerName = new Surface
      classes: ['status__pegger__name']
      size: [window.innerWidth, 30]
    peggerNameMod = new StateModifier
      align: [0.3, 0.1]
      origin: [0, 0]
    container.add(peggerNameMod).add @peggerName
    @points = new Surface
      classes: ['status__pegger__points']
      size: [window.innerWidth, 30]
    pointsMod = new StateModifier
      align: [0.3, 0.34]
      origin: [0, 0]
    container.add(pointsMod).add @points
    @add container

  _addChoice: ->
    @question = new Surface
      classes: ['status__pref__question']
      size: [50, 50]
      properties:
        borderRadius: '50px'
    questionMod = new StateModifier
      align: [0.1, 0]
      origin: [0, 0]
    container.add(questionMod).add @question

  load: (data) =>


module.exports = PrefStatusItemView
