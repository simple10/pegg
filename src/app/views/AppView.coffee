# AppView
#
# Main entry point of the app. Manages global views and events.


View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'
Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
Transitionable  = require 'famous/transitions/Transitionable'
Modifier = require 'famous/core/Modifier'
StateModifer = require 'famous/modifiers/StateModifier'
Lightbox = require 'famous/views/Lightbox'
Easing = require 'famous/transitions/Easing'

# Models
Questions = require 'collections/Questions'
Question = require 'models/Question'

# Views
HeaderView = require 'views/HeaderView'
MenuView = require 'views/MenuView'
CardView = require 'views/CardView'

# EditQuestionView = require 'views/EditQuestionView'
# ListQuestionsView = require 'views/ListQuestionsView'
# QuestionView = require 'views/QuestionView'
# ImageUploadView = require 'views/ImageUploadView'
# ImageEditView = require 'views/ImageEditView'


class AppView extends View
  @DEFAULT_OPTIONS:
    menu:
      width: 280
      transition:
        duration: 300
        curve: 'easeOut'
  pages: {}
  menuOpen: false

  constructor: ->
    super
    @layout = new HeaderFooterLayout
      headerSize: 60
      footerSize: 0
    @initHeader()
    @initMenu()
    @initPages()
    @initContent()
    @showPage 'card'

  initHeader: ->
    @header = new HeaderView
    @header.on 'toggleMenu', @toggleMenu
    @layout.header.add @header

  initMenu: ->
    @menuPosition = new Transitionable 0
    @menu = new MenuView
    @menu.resetBands()
    @menu.on 'toggleMenu', @toggleMenu
    @menu.on 'selectMenuItem', @selectMenuItem

  initPages: ->
    # Pages coorespond to menuID in MenuView
    @pages.card = new CardView
    @pages.peggboard = new Surface
      size: [0.8, 0.8]
      origin: [0.5, 0.5]
      content: '<h1>Test: Page 2</h1>'
      properties:
        backgroundColor: 'red'

  initContent: ->
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [0, 0]
      outOrigin: [0, 0]
      showOrigin: [0, 0]
      inTransform: Transform.thenMove(Transform.rotateX(0.9), [0, -300, -300])
      outTransform: Transform.thenMove(Transform.rotateZ(0.7), [0, window.innerHeight, -1000])
      inTransition: { duration: 650, curve: 'easeOut' }
      outTransition: { duration: 500, curve: Easing.inCubic }

    # Using a backing to hide the menu works but is problematic due
    # to perspective issues. Changing the position in z space causes
    # the backing to appear farther away and smaller. The menu would
    # also need to be pushed back in z space making it smaller.
    # The better solution is to animate the menu out of frame.
    bgModifier = new Modifier
      origin: [0, 0]
      transform: Transform.translate(0, 0, -100)
    @layout.content.add(bgModifier).add new Surface
      # Set the size for demo purposes so interference with the card flip is easier to see
      size: [500, 500]
      classes: ['content__background']

    @layout.content.add @lightbox

  showPage: (pageName) ->
    @lightbox.show @pages[pageName]

  toggleMenu: =>
    if @menuOpen
      @closeMenu()
    else
      @openMenu()

  selectMenuItem: (menuID) =>
    @showPage menuID
    @closeMenu()

  closeMenu: ->
    @menuPosition.set 0, @options.menu.transition, =>
      @menuOpen = false

  openMenu: ->
    @menu.animateBands()
    @menuPosition.set @options.menu.width, @options.menu.transition, =>
      @menuOpen = true

  # TODO: replace render with state modifiers.
  # Overriding render is suboptimal.
  # This code originally came from an old Famo.us example.
  render: ->
    [
        transform: Transform.translate 0, 0, -1
        target: @menu.render()
      ,
        transform: Transform.translate @menuPosition.get(), 0, 0
        target: @layout.render()
    ]

module.exports = AppView
