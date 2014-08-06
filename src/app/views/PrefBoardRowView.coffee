View = require 'famous/core/View'
SequentialLayout = require 'famous/views/SequentialLayout'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'

Utils = require 'lib/Utils'
PrefBoardImageView = require 'views/PrefBoardImageView'

class PrefBoardRowView extends View
  @DEFAULT_OPTIONS:
    data: []
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight()
    columns: 4
    gutter: 5
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
    for block in @options.data
      # offset is equal to album (width + gutter) * row position
      # multiply by -1 to move it off the screen
      offset = w * -1;
      mod = new StateModifier
        transform: Transform.translate(offset, 0, 0)
        opacity: 0.1
      mod._offset = offset

      image = new PrefBoardImageView
        gutter: @options.gutter
        width: w
        height:h
        url: block.imageUrl
        cardId: block.cardId
        userId: block.userId

      image.pipe @_eventOutput
      image._mod = mod
      
      @images.push(image)

    row = new SequentialLayout
      direction: Utility.Direction.X,
      itemSpacing: 0
      defaultItemSize: [w, h]
    row.sequenceFrom(@images)

    ## add to render tree
    @add(@mainMod).add(row)

  getImageWidth: () ->
    cols = @options.columns
    @options.width / cols

  getImageHeight: () ->
    @getImageWidth()

  # currently unused... to be used when animating in rows
  show: () ->
    for image in @images
      image._mod.setTransform(
        Transform.translate(0, 0, 0),
        @options.transition
      )

  # currently unused... to be used when animating in rows
  hide: () ->
    for image in @images
      mod = image._mod
      mod.setTransform(
        Transform.translate(mod._offset, 0, 0),
        @options.transition
      )
      mod.setOpacity(0.1, @options.transition)

module.exports = PrefBoardRowView
