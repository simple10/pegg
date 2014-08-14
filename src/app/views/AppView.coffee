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

# Helpers
Utils = require 'lib/Utils'

# Stores
AppStateStore = require 'stores/AppStateStore'

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
SettingsView = require 'views/SettingsView'
NewCardView = require 'views/NewCardView'
StatusView = require 'views/StatusView'
ReviewView = require 'views/ReviewView'
#MoodsView = require 'views/MoodsView'

# Layouts
PlayViewLayout = require 'views/layouts/mobile/PlayViewLayout'
NewCardViewLayout = require 'views/layouts/mobile/NewCardViewLayout'
HeaderViewLayout = require 'views/layouts/mobile/HeaderViewLayout'

#Actions
NavActions = require 'actions/NavActions'
AppStateStore = require 'stores/AppStateStore'
UserActions = require 'actions/UserActions'


class AppView extends View
  @DEFAULT_OPTIONS:
    menu:
      width: Utils.getViewportWidth() - 60
      transition:
        duration: 300
        curve: 'easeOut'
      model: Menu
    header:
      height: HeaderViewLayout.size[1]
  # Pages correspond to pageID in constants/menu.coffee
  pages: {}
  menuOpen: false

  constructor: ->
    super
    @initMenu()
    @initLayout()
    @initPages()
    @initListeners()
    NavActions.selectMenuItem AppStateStore.getCurrentPageID()

  initListeners: ->
    AppStateStore.on Constants.stores.MENU_CHANGE, @togglePage

  initMenu: ->
    @menu = new BandMenuView @options.menu
    @menu.on 'toggleMenu', @toggleMenu
    @menuState = new StateModifier
      origin: [0,0]
    @add(@menuState).add @menu

  initLayout: ->
    @layout = new HeaderFooterLayout
      headerSize: @options.header.height
      footerSize: 0
    @layout.header.add @initHeader()
#   @layout.footer.add @initFooter()
    @layout.content.add @initViewManager()
    @layoutState = new StateModifier
    @add(@layoutState).add @layout

  initHeader: ->
    @header = new HeaderView @options.header
    @header.on 'toggleMenu', @toggleMenu
    @header

#  initFooter: ->
#    @footer = new TabMenuView @options.menu
#    @footer

  initPages: ->
    # Pages correspond to pageID in constants/menu.coffee
    @pages.play = new PlayView PlayViewLayout
    @pages.create = new NewCardView NewCardViewLayout
    @pages.settings = new SettingsView
    @pages.activity = new ActivityView
    @pages.profile = new ProfileView
    @pages.review = new ReviewView
    @togglePage()

  initViewManager: ->
    viewportHeight = Utils.getViewportHeight()
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [1, 1]
      outOrigin: [0, 0]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.translate 0, viewportHeight, -300
      outTransform: Transform.translate 0, -viewportHeight, -1000
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }

  showPage: (page) ->
    @lightbox.show page

  getPage: (pageID) ->
    @pages[pageID]

  togglePage: =>
    pageID = AppStateStore.getCurrentPageID()
    if pageID is 'profile'
      UserActions.load() # load user pref images
    @showPage @getPage pageID
    #@footer.bounceTabs()
    #@footer.hideTabs()
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

#  onScroll: =>
#    if @tabsOpen
#      @footer.hideTabs()
#      @tabsOpen = false
#    else
#      @footer.showTabs()
#      @tabsOpen = true

module.exports = AppView
