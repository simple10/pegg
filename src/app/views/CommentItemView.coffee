require './scss/comments.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayStore = require 'stores/PlayStore'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
_ = require('Parse')._

class CommentsItemView extends View
  @DEFAULT_OPTIONS:
    width: undefined
    height: 60
    text:
      width: window.innerWidth - 87
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
      content: @comment.get 'userImg'
      classes: ['comments__pic']
    text = new Surface
      size: [@options.text.width, @options.text.height]
      classes: ['comments__text']
      content: @comment.get 'text'
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
