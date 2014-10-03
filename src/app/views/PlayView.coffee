# Famo.us
View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Lightbox = require 'famous/views/Lightbox'
Easing = require 'famous/transitions/Easing'

# Pegg
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
PlayCardView = require 'views/PlayCardView'
PlayStatusView = require 'views/PlayStatusView'
PlayBadgesView = require 'views/PlayBadgesView'
PickMoodView = require 'views/PickMoodView'
Utils = require 'lib/Utils'

class PlayView extends View

  constructor: (options) ->
    super options
    @initViews()
    @initListeners()

  initListeners: ->
    PlayStore.on Constants.stores.GAME_LOADED, @loadPage
    PlayStore.on Constants.stores.PAGE_CHANGE, @loadPage
    PlayStore.on Constants.stores.BADGE_CHANGE, @loadBadges
    PlayStore.on Constants.stores.MOODS_LOADED, @loadMoods


  initViews: ->

    ## MOOD STATUS ##
    @pickMood = new PickMoodView

    ## CARDS VIEW ##
    @playCardView = new PlayCardView

    ## BADGES VIEW ##
    @badgesView = new PlayBadgesView

    ## STATUS VIEW ##
    @statusView = new PlayStatusView

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

  loadMoods: =>
    @pickMood.load PlayStore.getMoods()
    @lightbox.show @pickMood

  loadBadges: =>
    @badgesView.load PlayStore.getBadges()
    @lightbox.show @badgesView

  loadPage: =>
    page = PlayStore.getCurrentPage()
    switch page.type
      when 'card'
        @playCardView.load page.card
        @lightbox.show @playCardView
      when 'status'
        @statusView.load page.status
        @lightbox.show @statusView
#      when "message"
##        @messageView.load page
##        @lightbox.show @messageView

module.exports = PlayView
