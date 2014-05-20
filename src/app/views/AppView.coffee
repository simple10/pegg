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

  menuOpen: false

  constructor: ->
    super
    @page = new HeaderFooterLayout
      headerSize: 60
      footerSize: 0
    @initHeader()
    @initMenu()
    @initContent()

  initHeader: ->
    @header = new HeaderView
    @header.on 'toggleMenu', @toggleMenu
    @page.header.add @header

  initMenu: ->
    @menuPosition = new Transitionable 0
    @menu = new MenuView
    @menu.resetBands()
    @menu.on 'toggleMenu', @toggleMenu

  initContent: ->
    # Using a backing to hide the menu works but is problematic due
    # to perspective issues. Changing the position in z space causes
    # the backing to appear farther away and smaller. The menu would
    # also need to be pushed back in z space making it smaller.
    # The better solution is to animate the menu out of frame.
    bgModifier = new Modifier
      origin: [0, 0]
      transform: Transform.translate(0, 0, -100)
    @page.content.add(bgModifier).add new Surface
      # Set the size for demo purposes so interference with the card flip is easier to see
      size: [500, 500]
      classes: ['content__background']

    @content = new CardView
    @contentState = new StateModifer
      origin: [0, 0.5]
    @contentState.setOrigin(
      [0.5, 0.5]
      duration: 500
      curve: 'easeOutBounce'
    )
    @page.content.add(@contentState).add @content

  toggleMenu: =>
    if @menuOpen
      @closeMenu()
    else
      @openMenu()

  closeMenu: ->
    @menuPosition.set 0, @options.menu.transition, =>
      @menuOpen = false

  openMenu: ->
    @menu.animateBands()
    @menuPosition.set @options.menu.width, @options.menu.transition, =>
      @menuOpen = true

  render: ->
    [
        transform: Transform.translate 0, 0, -1
        target: @menu.render()
      ,
        transform: Transform.translate @menuPosition.get(), 0, 0
        target: @page.render()
    ]

module.exports = AppView
