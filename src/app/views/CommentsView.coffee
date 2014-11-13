require './scss/comments.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
PlayStore = require 'stores/PlayStore'
Utility = require 'famous/src/utilities/Utility'
Scrollview = require 'famous/src/views/Scrollview'
CommentItemView = require 'views/CommentItemView'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Utils = require 'lib/Utils'

class CommentsView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth() - 50
    height: Utils.getViewportHeight() - 290

  constructor: () ->
    super
    @init()

  init: ->

    @container = new ContainerSurface
      size: [@options.width, @options.height]
      properties:
        overflow: 'hidden'
        # zIndex: -1
    @comments = new Scrollview
    @container.add @comments
    @addCommentText = new Surface
      classes: ['comments__text']
    @container.add @addCommentText
    @container.pipe @comments
    @add @container


  load: (data) ->
    # console.log 'loading comments', data
    surfaces = []
    @comments.sequenceFrom surfaces
    @i = 0
    if data? and data.length > 0
      while @i < data.length
        @addCommentText.setContent ''
        comment = new CommentItemView(data[@i], size: [@options.width, @options.height])
        comment.pipe @comments
        surfaces.push comment
        @i++
    else
      @addCommentText.setContent 'Don\'t be a weeniecorn, say something!'

  getCount: ->
    return @i

module.exports = CommentsView
