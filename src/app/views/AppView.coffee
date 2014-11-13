# AppView
#
# Main entry point of the app. Manages global views and events.

# CSS
require './scss/app.scss'

# Famous
Easing = require 'famous/src/transitions/Easing'
HeaderFooterLayout = require 'famous/src/views/HeaderFooterLayout'
Lightbox = require 'famous/src/views/Lightbox'
Modifier = require 'famous/src/core/Modifier'
RenderController = require 'famous/src/views/RenderController'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Transform = require 'famous/src/core/Transform'
Transitionable  = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Helpers
Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'

# Stores
AppStateStore = require 'stores/AppStateStore'
MessageStore = require 'stores/MessageStore'
SingleCardStore = require 'stores/SingleCardStore'
UserStore = require 'stores/UserStore'

# Menu
Menu = require 'constants/menu'

# Views
ActivityView = require 'views/ActivityView'
HeaderView = require 'views/HeaderView'
HomeView = require 'views/HomeView'
WeView = require 'views/WeView'
LayoutManager = require 'views/layouts/LayoutManager'
LoginView = require 'views/LoginView'
MessageView = require 'views/MessageView'
NewCardView = require 'views/NewCardView'
PeggBoxView = require 'views/PeggBoxView'
PlayCardView = require 'views/PlayCardView'
PlayView = require 'views/PlayView'
MeView = require 'views/MeView'
SettingsView = require 'views/SettingsView'
TabMenuView = require 'views/TabMenuView'


#Actions
NavActions = require 'actions/NavActions'
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
    @initMessage()
    #NavActions.selectMenuItem

  initListeners: ->
    AppStateStore.on Constants.stores.MENU_CHANGE, @togglePage
    SingleCardStore.on Constants.stores.REQUIRE_LOGIN, @requireLogin
    MessageStore.on Constants.stores.SHOW_MESSAGE, @showMessage
    MessageStore.on Constants.stores.HIDE_MESSAGE, @hideMessage
    SingleCardStore.on Constants.stores.CARD_CHANGE, @showSingleCard

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
      NavActions.selectMenuItem('us')
    @header

  initFooter: ->
    @footer = new TabMenuView @options.menu
    @footer

  initMessage: ->
    @messageRC = new RenderController
      inTransition:  { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    @messageView = new MessageView
    @messageView.on 'hide', @hideMessage
    @add @messageRC

  initPages: ->
    # Pages correspond to pageID in constants/menu.coffee
    @pages.play = new PlayView
    @pages.create = new NewCardView
    @pages.settings = new SettingsView
    @pages.activity = new ActivityView
    @pages.me = new MeView
    @pages.login = new LoginView
    @pages.we = new WeView
    @pages.card = new PlayCardView
      context: 'single_card'
    @togglePage()

  initViewManager: ->
    viewportHeight = Utils.getViewportHeight()
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [1, 1]
      outOrigin: [0, 0]
      showOrigin: [0.5, 0.5]
      # showTransform: Transform.translate null, null, -1
      inTransform: Transform.translate 0, viewportHeight, -300
      outTransform: Transform.translate 0, -viewportHeight, -1000
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }

  showMessage: (payload) =>
    @messageRC.show @messageView
    @messageView.load(payload)

  hideMessage: =>
    @messageRC.hide @messageView

  showPage: (page) ->
    @lightbox.show page

  getPage: (pageID) ->
    @pages[pageID]

  showSingleCard: =>
    @showPage @getPage 'card'

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
