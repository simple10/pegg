
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayStore = require 'stores/PlayStore'
Utility = require 'famous/utilities/Utility'
Scrollview = require 'famous/views/Scrollview'
CommentItemView = require 'views/CommentItemView'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

class CommentsView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth - 50
    height: window.innerHeight

  constructor: () ->
    super
    @init()

  init: ->
    @comments = new Scrollview
    #@add @comments

    container = new ContainerSurface
      size: [@options.width, @options.height]
      properties:
        overflow: 'hidden'
    container.add @comments
    @add container

    container.on 'click', =>
      @_eventOutput.emit 'click', @

  load: (data) ->
    surfaces = []
    @comments.sequenceFrom surfaces
    i = 0
    while i < data.length
      comment = new CommentItemView(data[i], size: [@options.width, @options.height])
      comment.pipe @comments
      surfaces.push comment
      i++

module.exports = CommentsView
