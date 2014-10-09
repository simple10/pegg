# Famo.us
View = require 'famous/src/core/View'
Transform = require 'famous/src/core/Transform'
Lightbox = require 'famous/src/views/Lightbox'
Easing = require 'famous/src/transitions/Easing'

# Pegg
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
PlayCardView = require 'views/PlayCardView'
PlayStatusView = require 'views/PlayStatusView'
PlayBadgesView = require 'views/PlayBadgesView'
PickMoodView = require 'views/PickMoodView'
PeggStatusView = require 'views/PeggStatusView'
PrefStatusView = require 'views/PrefStatusView'
DoneStatusView = require 'views/DoneStatusView'
Utils = require 'lib/Utils'

class PlayView extends View

  constructor: (options) ->
    super options
    @initViews()
    @initListeners()

  initListeners: ->
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

    ## PREF STATUS ##
    @prefStatus = new PrefStatusView

    ## PEGG STATUS ##
    @peggStatus = new PeggStatusView

    ## DONE STATUS ##
    @doneStatus = new DoneStatusView

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
