require './peggbox'

View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'

class ListItemView extends View
  @DEFAULT_OPTIONS:
    itemID: null
    message: null
    pic: null

  constructor: (options) ->
    super
    @init()

  init: ->
    @build()

  build: ->

    pic = @options.pic
    message = @options.message
    content = "
      <h2><img src='#{pic}' />#{message}</h2>
    "

    item = new Surface
      size: [undefined, 50]
      content: content
      classes: ['peggbox__item']

    item.on 'click', =>
      @_eventOutput.emit 'selectItem', @

    @.pipe item

    itemModifier = new StateModifier
      origin: [0, 0]
      align: [0.25, 0]

    @add(itemModifier).add item


module.exports = ListItemView
