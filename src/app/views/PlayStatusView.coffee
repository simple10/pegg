
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
PeggStatusView = require 'views/PeggStatusView'
PrefStatusView = require 'views/PrefStatusView'
DoneStatusView = require 'views/DoneStatusView'
Utils = require 'lib/Utils'
Lightbox = require 'famous/src/views/Lightbox'
Easing = require 'famous/src/transitions/Easing'

class PlayStatusView extends View

  constructor: (options) ->
    super options
    @init()

  init: ->
    ## PREF STATUS ##
    @prefStatus = new PrefStatusView @options.view

    ## PEGG STATUS ##
    @peggStatus = new PeggStatusView @options.view

    ## DONE STATUS ##
    @doneStatus = new DoneStatusView @options.view

    viewportWidth = Utils.getViewportWidth()
    @lightbox = new Lightbox
#      inOpacity: 1
#      outOpacity: 0
      inOrigin: [0, 0]
      outOrigin: [1, 0]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.translate viewportWidth, 0, -300
      outTransform: Transform.translate -viewportWidth, 0, -1000
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    @add @lightbox

  load: (status) ->
    switch status.type
      when 'friend_ranking'
        @peggStatus.load status
        @lightbox.show @peggStatus
      when 'likeness_report'
        @prefStatus.load status
        @lightbox.show @prefStatus
      when 'peggs_done', 'prefs_done'
        @doneStatus.load status
        @lightbox.show @doneStatus

  hide: ->
    @lightbox.hide()

module.exports = PlayStatusView
