require './scss/profile'

View = require 'famous/src/core/View'
Transform = require 'famous/src/core/Transform'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
NavActions = require 'actions/NavActions'
Utils = require 'lib/Utils'

class ProfileActivityItemView extends View
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
#      properties:
#        overflow: 'hidden'
      classes: ['profile__activity__item']
    container.pipe @._eventOutput

    question = @options.data.question
    plug = @options.data.plug

#    if @options.data.plug?
#      try
#        plug = JSON.parse(@options.data.plug).S3
#      catch
#        plug = ""
    numPegged = if @options.data.hasPegged? then @options.data.hasPegged.length else 0

    message = "
              <div class='outerContainer'>
                  <div class='innerContainer'>
                    #{question.truncate 55} <br/>
                    <span class='numPeggers'>Peggs #{numPegged}</span>
                </div>
               </div>
              "

    textSurface = new Surface
      size: [Utils.getViewportWidth() - 100, undefined]
      content: message
      classes: ['profile__activity__item__text']
    textSurfaceModifier = new StateModifier
      origin: [0, 0]
      align: [0, 0]
      transform: Transform.translate 70, null, null
    container.add(textSurfaceModifier).add textSurface

    picSurface = new ImageSurface
      size: [50, 50]
      classes: ['profile__activity__item__pic']
      content: plug
    picSurfaceMod = new StateModifier
      origin: [0, 0.5]
      align: [0, 0.5]
    container.add(picSurfaceMod).add picSurface
    @add container

    container.on 'click', ((e) ->
      NavActions.selectSingleCardItem @options.data.cardId, @options.data.userId, 'profile'
    ).bind @

module.exports = ProfileActivityItemView
