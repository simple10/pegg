# AppView
#
# Main entry point of the app. Manages global views and events.

# CSS
require './scss/app.scss'

View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'
Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
Transitionable  = require 'famous/transitions/Transitionable'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Lightbox = require 'famous/views/Lightbox'
Easing = require 'famous/transitions/Easing'
Constants = require 'constants/PeggConstants'

# Stores
AppStateStore = require 'stores/AppStateStore'
PeggBoxStore = require 'stores/PeggBoxStore'
PlayStore = require 'stores/PlayStore'
MoodStore = require 'stores/MoodStore'

# Actions
PeggBoxActions = require 'actions/PeggBoxActions'

# Menu
Menu = require 'constants/menu'

# Views
HeaderView = require 'views/HeaderView'
TabMenuView = require 'views/TabMenuView'
BandMenuView = require 'views/BandMenuView'
PeggBoxView = require 'views/PeggBoxView'
PlayView = require 'views/PlayView'
ProfileView = require 'views/ProfileView'
ActivityView = require 'views/ActivityView'
DecksView = require 'views/DecksView'
NewCardView = require 'views/NewCardView'
StatusView = require 'views/StatusView'
#MoodsView = require 'views/MoodsView'

# Layouts
PlayViewLayout = require 'views/layouts/iPhone5/PlayViewLayout'


class AppView extends View
  @DEFAULT_OPTIONS:
    menu:
      width: 270
      transition:
        duration: 300
        curve: 'easeOut'
      model: Menu
    header:
      height: 50
  # Pages correspond to pageID in constants/menu.coffee
  pages: {}
  menuOpen: false

  constructor: ->
    super
    @initMenu()
    @initLayout()
    @initPages()
    @initListeners()

  initListeners: ->
    AppStateStore.on Constants.stores.CHANGE, @togglePage
    PlayStore.on Constants.stores.PLAY_CHANGE, @togglePage
    #MoodStore.on Constants.stores.CHANGE, @onMoodChange
    #PlayStore.on Constants.stores.UNLOCK_ACHIEVED, @onStatusChange
    #PlayStore.on Constants.stores.PLAY_CONTINUED, @onPlayContinued
    #@pages.peggbox.on 'scroll', @onScroll

  initMenu: ->
    @menu = new BandMenuView @options.menu
    #@menu.resetBands()
    @menu.on 'toggleMenu', @toggleMenu
    @menuState = new StateModifier
      origin: [0,0]
    @add(@menuState).add @menu

  initLayout: ->
    @layout = new HeaderFooterLayout
      headerSize: @options.header.height
      footerSize: 0
    @layout.header.add @initHeader()
    @layout.footer.add @initFooter()
    @layout.content.add @initViewManager()
    @layoutState = new StateModifier
    @add(@layoutState).add @layout

  initFooter: ->
    @footer = new TabMenuView @options.menu
    @footer

  initHeader: ->
    @header = new HeaderView @options.header
    @header.on 'toggleMenu', @toggleMenu
    @header

  initPages: ->
    # Pages correspond to pageID in constants/menu.coffee
    @pages.play = new PlayView PlayViewLayout
    @pages.create = new NewCardView
    @pages.decks = new DecksView
    @pages.activity = new PeggBoxView
    @pages.profile = new ProfileView
    @pages.peggbox = new PeggBoxView
    @pages.status = new StatusView
    #@pages.moods = new MoodsView

  initViewManager: ->
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [1, 1]
      outOrigin: [0, 0]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.thenMove(Transform.rotateX(1), [0, window.innerHeight, -300])
      outTransform: Transform.thenMove(Transform.rotateZ(0.7), [0, -window.innerHeight, -1000])
      inTransition: { duration: 1000, curve: Easing.outExpo }
      outTransition: { duration: 500, curve: Easing.inCubic }

  showPage: (page) ->
    @lightbox.show page

  getPage: (pageID) ->
    @pages[pageID]

  togglePage: =>
    pageID = AppStateStore.getCurrentPageID()
    if pageID is 'play'
      #playState = PlayStore.getPlayState()
      #if playState is Constants.stores.NO_PEGGS_REMAINING
      #  @showPage @pages.status
      #else
        @showPage @pages.play
    else
      @showPage @getPage pageID
    #@footer.bounceTabs()
    @footer.hideTabs()
    @closeMenu()

  toggleMenu: =>
    if @menuOpen
      @closeMenu()
    else
      @openMenu()

  closeMenu: ->
    @layoutState.setTransform(
      Transform.translate 0, 0, 0
      @options.menu.transition
      =>
        @menuOpen = false
    )
    @menu.hide()

  openMenu: ->
    @layoutState.setTransform(
      Transform.translate @options.menu.width, 0, 0
      @options.menu.transition
      =>
        @menuOpen = true
    )
    @menu.show()

  onScroll: =>
    if @tabsOpen
      @footer.hideTabs()
      @tabsOpen = false
    else
      @footer.showTabs()
      @tabsOpen = true

module.exports = AppView
