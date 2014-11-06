# Famo.us
Easing = require 'famous/src/transitions/Easing'
Lightbox = require 'famous/src/views/Lightbox'
RenderController = require 'famous/src/views/RenderController'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
View = require 'famous/src/core/View'

# Pegg
Constants = require 'constants/PeggConstants'
DoneStatusView = require 'views/DoneStatusView'
LayoutManager = require 'views/layouts/LayoutManager'
PeggStatusView = require 'views/PeggStatusView'
PickMoodView = require 'views/PickMoodView'
PlayBadgesView = require 'views/PlayBadgesView'
PlayCardView = require 'views/PlayCardView'
PlayStatusView = require 'views/PlayStatusView'
PlayStore = require 'stores/PlayStore'
PrefStatusView = require 'views/PrefStatusView'
ProgressBarView = require 'views/ProgressBarView'
Utils = require 'lib/Utils'

class PlayView extends View

  constructor: (options) ->
    super options
    layoutManager = new LayoutManager()
    @layout = layoutManager.getViewLayout 'PlayView'
    @initViews()
    @initListeners()

  initListeners: ->
    PlayStore.on Constants.stores.PAGE_CHANGE, @loadPage
    PlayStore.on Constants.stores.BADGE_CHANGE, @loadBadge
    PlayStore.on Constants.stores.MOODS_LOADED, @loadMoods
    PlayStore.on Constants.stores.GAME_LOADED, @loadGame

    @playCardView.on 'back', @backTransition
    @playCardView.on 'forward', @forwardTransition

  initViews: ->

    ## PROGRESS BAR ##
    @progressBar = new ProgressBarView
    @progressBarRc = new RenderController
      inTransition:  @layout.progress.inTransition
      outTransition: @layout.progress.outTransition
    progressBarMod = new StateModifier
      align: @layout.progress.align
      origin: @layout.progress.origin
    @add(progressBarMod).add @progressBarRc

    ## MOOD STATUS ##
    @pickMood = new PickMoodView

    ## CARDS VIEW ##
    @playCardView = new PlayCardView
      context: 'play'

    ## BADGES VIEW ##
    @badgesView = new PlayBadgesView

    ## PREF STATUS ##
    @prefStatus = new PrefStatusView

    ## PEGG STATUS ##
    @peggStatus = new PeggStatusView

    ## DONE STATUS ##
    @doneStatus = new DoneStatusView

    @lightbox = new Lightbox
#      inOpacity: 1
#      outOpacity: 0
#      inOrigin: [0, 0]
#      outOrigin: [1, 0]
      showOrigin: [0.5, 0.5]
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 500, curve: Easing.outCubic }
      overlap: true
    @add @lightbox
    @forwardTransition()

  backTransition: =>
    viewportWidth = Utils.getViewportWidth()
    @lightbox.setOptions
      inTransform: Transform.translate -viewportWidth, 0, null
      outTransform: Transform.translate viewportWidth, 0, null

  forwardTransition: =>
    viewportWidth = Utils.getViewportWidth()
    @lightbox.setOptions
      inTransform: Transform.translate viewportWidth, 0, null
      outTransform: Transform.translate -viewportWidth, 0, null

  loadGame: =>
    @progressBarRc.show @progressBar
    gameState = PlayStore.getGameState()
    @progressBar.reset gameState.size

  loadMoods: =>
    @backTransition()
    @progressBarRc.hide @progressBar
    @pickMood.load PlayStore.getMoods()
    @lightbox.show @pickMood, @forwardTransition

  loadBadge: =>
    @badgesView.load PlayStore.getBadge()
    @lightbox.show @badgesView

  loadPage: =>
    page = PlayStore.getCurrentPage()
    position = PlayStore.getCurrentPosition() + 1
    @progressBar.setPosition position
    switch page.type
      when 'card'
        @lightbox.hide null, =>
          @playCardView.snapToOrigin 'X', 0
          @lightbox.show @playCardView
      when 'topPeggers'
        @peggStatus.load page.stats
        @lightbox.show @peggStatus
      when 'prefPopularities'
        @prefStatus.load page.stats
        @lightbox.show @prefStatus
      when 'done'
        @lightbox.show @doneStatus
#      when "message"
##        @messageView.load page
##        @lightbox.show @messageView

module.exports = PlayView
