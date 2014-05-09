View = require 'famous/core/View'
Surface = require 'famous/core/Surface'


class MenuView extends View
  constructor: ->
    super
    @surface = new Surface
      size: [280, undefined]
      content: 'MENU!!!'

    @add @surface


module.exports = MenuView
