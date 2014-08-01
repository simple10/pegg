View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Transform = require 'famous/core/Transform'

Utils = require 'lib/Utils'

class PeggBoardImageView extends View
  @DEFAULT_OPTIONS:
    data: {}
    height: 100
    width: 100

  constructor: (options) ->
    super options

    @initSurfaces()

  initSurfaces: () ->
    
    ## Container ##
    @container = new ContainerSurface
      size: [@options.width, @options.height]
      properties:
        overflow: 'hidden'

    ## Image ##
    @image = new ImageSurface
      size: [true, true]
      content: 'http://media0.giphy.com/media/jj2A4jj5D2qre/200.gif'
    @imageMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]

    ## Add to render tree
    @add(@container).add(@imageMod).add(@image)

  _updateImageSize: () ->
    # TODO - use original image ratio to determine new image size

  showFullSize: () ->
    # TODO - black out the background, show a larger version of the image, display a nav bar


module.exports = PeggBoardImageView