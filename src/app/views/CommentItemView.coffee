require './scss/comments.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
PlayStore = require 'stores/PlayStore'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
_ = require('Parse')._
Utils = require 'lib/Utils'

class CommentsItemView extends View
  @DEFAULT_OPTIONS:
    width: undefined
    height: 60
    text:
      width: Utils.getViewportWidth() - 87
      height: 15
    pic:
      width: 35
      height: 35

  constructor: (comment, options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @comment = comment
    @addItem()

  addItem: ->

    pic = new ImageSurface
      size: [@options.pic.width, @options.pic.height]
      content: @comment.userImg
      classes: ['comments__pic']
    text = new Surface
      size: [@options.text.width, @options.text.height]
      classes: ['comments__text']
      content: @comment.text
      properties:
        marginLeft: @options.pic.width + 10 + 'px'
    #@add pic
    #@add text

    container = new ContainerSurface
      size: [@options.width, @options.height]
      classes: ['comments__item']
      properties:
        overflow: 'hidden'
    container.add pic
    container.add text
    @add container

    container.pipe @_eventOutput

module.exports = CommentsItemView
