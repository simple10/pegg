# Famo.us
View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Lightbox = require 'famous/views/Lightbox'
Easing = require 'famous/transitions/Easing'

# Pegg
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
HomeMenuView = require 'views/HomeMenuView'
ActivityView = require 'views/ActivityView'
Utils = require 'lib/Utils'

class HomeView extends View

  constructor: (options) ->
    super options
    @initViews()

  initViews: ->

    ## MAIN MENU ##
    @homeMenuView = new HomeMenuView
    @homeMenuView.on 'pageSelect', (page) =>
      @loadPage page

    ## ACTIVITY ##
    @activityView = new ActivityView
    @activityView.on 'back', @loadPage

    viewportWidth = Utils.getViewportWidth()
    @lightbox = new Lightbox
      inOrigin: [0, 0]
      outOrigin: [1, 0]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.translate viewportWidth, 0, -300
      outTransform: Transform.translate -viewportWidth, 0, -1000
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    @add @lightbox

    @lightbox.show @homeMenuView
    @direction = 1

  loadPage: (page) =>
    switch page
      when 'Home'
        @reverseLightbox()
        @lightbox.show @homeMenuView
      when 'Activity'
        @reverseLightbox()
        @lightbox.show @activityView

#      when 'challenges'
#        @lightbox.show @challengesView
#      when 'stats'
#        @lightbox.show @statsView
#      when 'peggbox'
#        @lightbox.show @peggboxView

  reverseLightbox: () =>
    if @direction is -1
      @lightbox.setOptions
        inTransform: Transform.translate -Utils.getViewportWidth(), 0, -1000
        outTransform: Transform.translate Utils.getViewportWidth(), 0, -300
      @direction = 1
    else
      @lightbox.setOptions
        outTransform: Transform.translate -Utils.getViewportWidth(), 0, -1000
        inTransform: Transform.translate Utils.getViewportWidth(), 0, -300
      @direction = -1


module.exports = HomeView
