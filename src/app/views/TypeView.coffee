require './scss/login.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'

class TypeView extends View

  constructor: (options) ->
    super options
    @init()

  init: ->
    markSurface = new Surface
      size: @options.size
      classes: @options.classes
      content: "<svg version='1.1' id='Layer_1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px'
      	 width='#{@options.size[0]}px' height='#{@options.size[1]}px' viewBox='0 0 425.197 198.425' enable-background='new 0 0 425.197 198.425'
      	 xml:space='preserve'>
      <path fill='none' class='path' stroke='#FFFFFF' stroke-width='8' stroke-linecap='round' d='M309.802,83.75
      	c3.945,7.073,10.229,12.376,18.097,14.392c16.811,4.306,34.493-8.025,39.494-27.545c0.718-2.799,1.126-5.595,1.265-8.342
      	c0,0-6.574,97.333-33.43,112.123c-26.854,14.79-40.866-28.254-7.784-41.255c33.083-13.001,68.5-35.805,76.284-47.871'/>
      <path fill='none' class='path' stroke='#FFFFFF' stroke-width='8' stroke-linecap='round' d='M273.732,62.255c0,0-6.574,97.333-33.429,112.123
      	c-26.855,14.79-40.867-28.254-7.784-41.255c33.081-13.001,69.085-36.109,77.283-49.372c-4.484-8.04-5.948-18.366-3.288-28.75
      	c5.001-19.52,22.682-31.854,39.493-27.546c14.401,3.69,23.482,18.392,22.65,34.8'/>
      <path fill='none' class='path' stroke='#FFFFFF' stroke-width='8' stroke-linecap='round' d='M212.481,78.462
      	c3.461,9.672,10.766,17.188,20.492,19.68c16.811,4.306,34.495-8.025,39.493-27.545c5.001-19.519-4.572-38.834-21.385-43.142
      	c-16.812-4.308-34.493,8.026-39.494,27.546C209.48,63.227,209.961,71.417,212.481,78.462c0,0-8.471,18.661-23.552,20.538
      	c-17.835,2.22-40.319-9.586-43.979-37.021c-3.309-24.795,10.282-42.55,23.546-35.381c16.346,8.834,1.341,39.668-13.427,57.486
      	c-16.542,19.957-39.441,23.19-72.134,2.173C50.241,65.24,42.979,97.316,74.893,98.873c31.915,1.556,54.116-61.671,17.125-72.391
      	c-33.117-9.598-49.817,32.303-49.817,32.303l-0.929,1.521l4.431-33.823l-19.071,145.56'/>
      "
    markMod = new StateModifier
      origin: @options.origin
      align: @options.align
    @add(markMod).add markSurface

module.exports = TypeView
