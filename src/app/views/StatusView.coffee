
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
PeggStatusView = require 'views/PeggStatusView'
PrefStatusView = require 'views/PrefStatusView'
Utils = require 'lib/Utils'

class StatusView extends View

  constructor: (options) ->
    super options
    @init()

  init: ->

    container = new ContainerSurface
      size: @options.view.size

    ## PREF STATUS ##
    @prefStatus = new PrefStatusView
      size: @options.view.size
    @prefStatusMod = new StateModifier
      align: @options.view.align
      origin: @options.view.origin
    container.add(@prefStatusMod).add @prefStatus

    ## PEGG STATUS ##
    @peggStatus = new PeggStatusView
      size: @options.view.size
    @peggStatusMod = new StateModifier
      align: @options.view.align
      origin: @options.view.origin
    container.add(@peggStatusMod).add @peggStatus

    @add container

  load: (status) ->
    switch status.type
      when 'friend_ranking'
        @peggStatus.load status
        Utils.animate @prefStatusMod, @options.view.states[1]
        Utils.animate @peggStatusMod, @options.view.states[0]
      when 'likeness_report'
        @prefStatus.load status
        Utils.animate @prefStatusMod, @options.view.states[0]
        Utils.animate @peggStatusMod, @options.view.states[1]


module.exports = StatusView
