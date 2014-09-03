View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Transform = require 'famous/core/Transform'
NavActions = require 'actions/NavActions'
SingleCardActions = require 'actions/SingleCardActions'

Utils = require 'lib/Utils'

class PrefBoardImageView extends View
  @DEFAULT_OPTIONS:
    url: 'http://media0.giphy.com/media/jj2A4jj5D2qre/200.gif'
    height: 100
    width: 100
    gutter: 5

  constructor: (options) ->
    super options

    @initSurfaces()
    @initListeners()

  initSurfaces: () ->
    
    ## Container ##
    @containerMod = new StateModifier
      size: [@options.width, @options.height]
    @container = new ContainerSurface
      size: [@options.width - @options.gutter, @options.height - @options.gutter]
      properties:
        overflow: 'hidden'
        margin: ~~(@options.gutter/2)+'px'

    ## Image ##
    @image = new ImageSurface
      size: [undefined, undefined]
      content: @options.url
    @imageMod = new StateModifier
      origin: [0, 0]
      align: [0, 0]
      opacity: 0

    # Need to wait until the surface is rendered before trying to attach the 'load' eventlistener
    @image.on 'deploy', () =>
      @image._element.addEventListener 'load', @_showImage.bind(@)

    ## Add to render tree
    @container.add(@imageMod).add(@image)
    @add(@containerMod).add(@container)

  initListeners: () ->
    @image.pipe @_eventOutput
    @image.on 'click', ((e) ->
      SingleCardActions.load @options.cardId, @options.userId, 'profile'
      NavActions.selectSingleCardItem @options.cardId, @options.userId
    ).bind @

  _showImage: ->
    transition = {
      duration : 1000,
      curve: 'easeInOut'
    }
    @imageMod.setOpacity 1, transition

  showFullSize: () ->
    # TODO - black out the background, show a larger version of the image, display a nav bar


module.exports = PrefBoardImageView
