# AppView
#
# Main entry point of the app. Manages global views and events.


View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'
Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
Transitionable  = require 'famous/transitions/Transitionable'


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
      footerSize: 50
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
    @menu.on 'toggleMenu', @toggleMenu

  initContent: ->
    @content = new CardView
    @page.content.add @content

  toggleMenu: =>
    if @menuOpen
      @closeMenu()
    else
      @openMenu()

  closeMenu: ->
    @menuPosition.set 0, @options.menu.transition, =>
      @menuOpen = false

  openMenu: ->
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