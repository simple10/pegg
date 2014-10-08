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
UserStore = require 'stores/UserStore'
SingleCardStore = require 'stores/SingleCardStore'

# Menu
Menu = require 'constants/menu'

# Views
HeaderView = require 'views/HeaderView'
TabMenuView = require 'views/TabMenuView'
PeggBoxView = require 'views/PeggBoxView'
PlayView = require 'views/PlayView'
ProfileView = require 'views/ProfileView'
ActivityView = require 'views/ActivityView'
SettingsView = require 'views/SettingsView'
NewCardView = require 'views/NewCardView'
LoginView = require 'views/LoginView'
HomeView = require 'views/HomeView'
LayoutManager = require 'views/layouts/LayoutManager'


#Actions
NavActions = require 'actions/NavActions'
AppStateStore = require 'stores/AppStateStore'
UserActions = require 'actions/UserActions'


class AppView extends View
  @DEFAULT_OPTIONS:
    menu:
      model: Menu
    header:
      height: 0
  # Pages correspond to pageID in constants/menu.coffee
  pages: {}
  menuOpen: false

  constructor: ->
    super

    @layoutManager = new LayoutManager()
    @footerLayout = @layoutManager.getViewLayout 'FooterView'

    @initLayout()
    @initPages()
    @initListeners()
    #NavActions.selectMenuItem

  initListeners: ->
    AppStateStore.on Constants.stores.MENU_CHANGE, @togglePage
    SingleCardStore.on Constants.stores.REQUIRE_LOGIN, @requireLogin

  initLayout: ->
    @layout = new HeaderFooterLayout
      headerSize: @options.header.height
      footerSize: @footerLayout.height
    @layout.header.add @initHeader()
    @layout.footer.add @initFooter()
    @layout.content.add @initViewManager()
    @layoutState = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
    @add(@layoutState).add @layout

  initHeader: ->
    @header = new HeaderView height: 50
    @header.on 'toggleMenu', =>
      NavActions.selectMenuItem('home')
    @header

  initFooter: ->
    @footer = new TabMenuView @options.menu
    @footer

  initPages: ->
    # Pages correspond to pageID in constants/menu.coffee
    @pages.play = new PlayView
    @pages.create = new NewCardView
    @pages.settings = new SettingsView
    @pages.activity = new ActivityView
    @pages.profile = new ProfileView
    @pages.login = new LoginView
    @pages.home = new HomeView
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
    if !UserStore.getLoggedIn() and pageID isnt 'card'
      @requireLogin()
    else
      @showPage @getPage pageID
      @footer.bounceTabs()
#      @footer.hideTabs()

  requireLogin: =>
    @showPage @getPage 'login'

  onScroll: =>
    if @tabsOpen
      @footer.hideTabs()
      @tabsOpen = false
    else
      @footer.showTabs()
      @tabsOpen = true

module.exports = AppView
