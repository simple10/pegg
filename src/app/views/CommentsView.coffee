require './scss/comments.scss'

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
Utils = require 'lib/Utils'

class CommentsView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth() - 50
    height: Utils.getViewportHeight() - 290

  constructor: () ->
    super
    @init()

  init: ->

    @comments = new Scrollview
    @container = new ContainerSurface
      size: [@options.width, @options.height]
      properties:
        overflow: 'hidden'
    @container.add @comments
    @addCommentText = new Surface
      classes: ['comments__text']
    @container.add @addCommentText
    @add @container


  load: (data) ->
#   console.log 'loading comments', data
    surfaces = []
    @comments.sequenceFrom surfaces
    @i = 0
    while @i < data.length
      @addCommentText.setContent ''
      comment = new CommentItemView(data[@i], size: [@options.width, @options.height])
      comment.pipe @comments
      surfaces.push comment
      @i++
    if data.length is 0
      @addCommentText.setContent 'No comments yet... Don\'t be a weeniecorn, say something.'

  getCount: ->
    return @i

module.exports = CommentsView
