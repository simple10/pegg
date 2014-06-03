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

# Models
Menu = require 'models/menu'
Activity = require 'models/activity'

# Views
HeaderView = require 'views/HeaderView'
CardView = require 'views/CardView'
NewCardView = require 'views/NewCardView'
TabMenuView = require 'views/TabMenuView'
BandMenuView = require 'views/BandMenuView'
PeggBoxView = require 'views/PeggBoxView'


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
    @initMenu()
    @initMain()
    @initPages()
    @showPage @getPage 'play'

  initMenu: ->
    @menu = new BandMenuView @options.menu
    @menu.resetBands()
    @menu.on 'toggleMenu', @toggleMenu
    @menu.on 'selectMenuItem', @selectMenuItem
    @menuState = new StateModifier
    @add(@menuState).add @menu

  initMain: ->
    @layout = new HeaderFooterLayout
      headerSize: 60
      footerSize: 100
    @layout.header.add @initHeader()
    @layout.footer.add @initFooter()
    @layout.content.add @initViewManager()
    @layoutState = new StateModifier
    @add(@layoutState).add @layout


  initFooter: ->
    @footer = new TabMenuView @options.menu
    @footer.showTabs()
    @footer.on 'selectTabMenuItem', @selectTabMenuItem
    @footer

  initHeader: ->
    @header = new HeaderView
    @header.on 'toggleMenu', @toggleMenu
    @header

  initPages: ->
    # Pages correspond to menuID in MenuView
    @pages.play = new CardView
    @pages.newCard = new NewCardView
    @pages.peggbox = new PeggBoxView
      model: Activity

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

  selectMenuItem: (pageID) =>
    @showPage @getPage pageID
    @closeMenu()

  selectTabMenuItem: (pageID) =>
    @showPage @getPage pageID
    @footer.hideTabs()
    @footer.showTabs()

  closeMenu: ->
    @layoutState.setTransform(
      Transform.translate 0, 0, 0
      @options.menu.transition
      =>
        @menuOpen = false
    )
    # TODO: animate menu into screen - moved to MenuView
    @menu.hide()

  openMenu: ->
    @layoutState.setTransform(
      Transform.translate @options.menu.width, 0, 0
      @options.menu.transition
      =>
        @menuOpen = true
    )
    # TODO: animate menu offscreen to hide menu background - moved to MenuView
    @menu.show()


module.exports = AppView
