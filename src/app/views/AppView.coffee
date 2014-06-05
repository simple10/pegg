# AppView
#
# Main entry point of the app. Manages global views and events.

# CSS
require './app.scss'

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

# Actions
PeggBoxActions = require 'actions/PeggBoxActions'
PlayActions = require 'actions/PlayActions'

# Menu
Menu = require 'constants/menu'

# Views
HeaderView = require 'views/HeaderView'
TabMenuView = require 'views/TabMenuView'
BandMenuView = require 'views/BandMenuView'
PeggBoxView = require 'views/PeggBoxView'
PlayView = require 'views/PlayView'
NewCardView = require 'views/NewCardView'

class AppView extends View
  @DEFAULT_OPTIONS:
    menu:
      width: 280
      transition:
        duration: 300
        curve: 'easeOut'
      model: Menu
  # pages keys correspond to pageID in MenuView
  pages: {}
  menuOpen: false

  constructor: ->
    super
    @initData()
    @initMenu()
    @initMain()
    @initPages()
    @initListeners()
    @onAppStoreChange()

  initListeners: ->
    AppStateStore.on Constants.stores.CHANGE, @onAppStoreChange
    PeggBoxStore.on Constants.stores.CHANGE, @onPeggBoxChange
    PlayStore.on Constants.stores.CHANGE, @onPlayChange

  initData: ->
    PeggBoxActions.load 0
    PlayActions.load 0

  initMenu: ->
    @menu = new BandMenuView @options.menu
    @menu.resetBands()
    @menu.on 'toggleMenu', @toggleMenu
    @menuState = new StateModifier
    @add(@menuState).add @menu

  initMain: ->
    @layout = new HeaderFooterLayout
      headerSize: 60
      footerSize: 60
    @layout.header.add @initHeader()
    @layout.footer.add @initFooter()
    @layout.content.add @initViewManager()
    @layoutState = new StateModifier
    @add(@layoutState).add @layout


  initFooter: ->
    @footer = new TabMenuView @options.menu
    @footer.resetTabs()
    @footer

  initHeader: ->
    @header = new HeaderView
    @header.on 'toggleMenu', @toggleMenu
    @header

  initPages: ->
    # Pages correspond to pageID in constants/menu.coffee
    @pages.newCard = new NewCardView
    @pages.peggbox = new PeggBoxView
    @pages.play = new PlayView

  initViewManager: ->
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [0, 0]
      outOrigin: [1, 1]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.thenMove(Transform.rotateX(1), [0, -300, -300])
      outTransform: Transform.thenMove(Transform.rotateZ(0.7), [0, window.innerHeight, -1000])
      inTransition: { duration: 650, curve: 'easeOut' }
      outTransition: { duration: 500, curve: Easing.inCubic }

  showPage: (page) ->
    @lightbox.show page

  getPage: (pageID) ->
    @pages[pageID]

  toggleMenu: =>
    if @menuOpen
      @closeMenu()
    else
      @openMenu()

  onAppStoreChange: =>
    @showPage @getPage AppStateStore.getCurrentPageID()
    @footer.hideTabs()
    @footer.showTabs()
    @closeMenu()

  onPeggBoxChange: =>
    @pages.peggbox.load PeggBoxStore.getNextSet()

  onPlayChange: =>
    @pages.play.load PlayStore.getGame()

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


module.exports = AppView
