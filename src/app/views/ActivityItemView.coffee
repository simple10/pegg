require './scss/peggbox'

View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
NavActions = require 'actions/NavActions'
ReviewActions = require 'actions/ReviewActions'
Utils = require 'lib/Utils';

class ActivityItemView extends View
  @DEFAULT_OPTIONS:
    itemID: null
    message: null
    pic: null
    height: 100

  constructor: (options) ->
    super options
    @init()

  init: ->
    @build()

  build: ->
    container = new ContainerSurface
      size: [Utils.getViewportWidth(), @options.height]
      properties:
        overflow: 'hidden'
      classes: ['peggbox__item']
    container.pipe @._eventOutput

    peggeeName = @options.peggee.get 'first_name'
    peggerName = @options.pegger.get 'first_name'
    peggerPic = @options.pegger.get 'avatar_url'
    guess = @options.guess.get 'text'
    message = "
          <div class='peggbox__item__text__child'>
            <span class='pegger'>#{peggerName}</span> pegged #{peggeeName} with #{guess.truncate 15}
          </div>
      ​​​​​​​​​​​​​​​​​​​​​​"

    textSurface = new Surface
      size: [Utils.getViewportWidth() - 80, @options.height]
      content: message
      properties:
        width: Utils.getViewportWidth()
      classes: ['peggbox__item__text']
    textSurfaceModifier = new StateModifier
      origin: [0, 0]
      align: [0, 0]
      transform: Transform.translate 80, null, null
    container.add(textSurfaceModifier).add textSurface

    picSurface = new ImageSurface
      size: [50, 50]
      classes: ['peggbox__item__pic']
      content: peggerPic
    picSurfaceMod = new StateModifier
      origin: [0, 0.5]
      align: [0.05, 0.5]
    container.add(picSurfaceMod).add picSurface
    @add container

    container.on 'click', ((e) ->
      ReviewActions.load @options.card.id, @options.peggee.id
      NavActions.selectReviewItem @options.card.id, @options.peggee.id
    ).bind @

module.exports = ActivityItemView
