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

class CommentsView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth - 50
    height: window.innerHeight - 300

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
    @container.on 'click', =>
      @_eventOutput.emit 'open', @
    @add @container

  load: (data) ->
    surfaces = []
    @comments.sequenceFrom surfaces
    i = 0
    while i < data.length
      comment = new CommentItemView(data[i], size: [@options.width, @options.height])
      comment.pipe @comments
      surfaces.push comment
      i++
    if data.length is 0
      addCommentText = new Surface
        classes: ['comments__text']
        content: 'Tap here to enter a comment'
      addCommentText.on 'click', =>
        addCommentText.setContent ''
        @_eventOutput.emit 'open', @
      @container.add addCommentText

module.exports = CommentsView
