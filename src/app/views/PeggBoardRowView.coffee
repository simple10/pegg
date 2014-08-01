View = require 'famous/core/View'
SequentialLayout = require 'famous/views/SequentialLayout'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'

Utils = require 'lib/Utils'
PeggBoardImageView = require 'views/PeggBoardImageView'

class PeggBoardRowView extends View
  @DEFAULT_OPTIONS:
    data: []
    columns: 4
    spacing: 5
    transition: {
      duration: 300
      curve: 'easeInOut'
    }

  constructor: (options) ->
    super options

    @initSurfaces()

  initSurfaces: () ->
    w = @getImageWidth()
    h = @getImageHeight()

    @mainMod = new StateModifier
      size: [null, h]

    @images = []
    for datum,i in @options.data
      # offset is equal to album (width + spacing) * row position
      # multiply by -1 to move it off the screen
      offset = (w + @options.spacing) * (i+1) * -1;
      mod = new StateModifier
        transform: Transform.translate(offset, 0, 0)
        opacity: 0.1
      mod._offset = offset

      image = new PeggBoardImageView
        width: w
        height:h
        data: datum
      image._mod = mod;
      
      @images.push(image)

    row = new SequentialLayout
      direction: Utility.Direction.X,
      itemSpacing: 5
      defaultItemSize: [w, h]
    row.sequenceFrom(@images)

    ## add to render tree
    @add(@mainMod).add(row)

  getImageWidth: () ->
    cols = @options.columns
    (Utils.getViewportWidth() - (cols - 1) * @options.spacing) / cols

  getImageHeight: () ->
    @getImageWidth()

  show: () ->
    for image in @images
      image._mod.setTransform(
        Transform.translate(0, 0, 0),
        @options.transition
      )

  hide: () ->
    for image in @images
      mod = image._mod
      mod.setTransform(
        Transform.translate(mod._offset, 0, 0),
        @options.transition
      )
      mod.setOpacity(0.1, @options.transition)

module.exports = PeggBoardRowView