require './scss/profile.scss'

# Famo.us
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Easing = require 'famous/transitions/Easing'
GenericSync = require 'famous/inputs/GenericSync'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
MouseSync = require 'famous/inputs/MouseSync'
RenderNode = require 'famous/core/RenderNode'
Scrollview = require 'famous/views/Scrollview'
SequentialLayout = require 'famous/views/SequentialLayout'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
Timer = require 'famous/utilities/Timer'
TouchSync = require 'famous/inputs/TouchSync'
Transform = require 'famous/core/Transform'
Transitionable = require 'famous/transitions/Transitionable'
Utility = require 'famous/utilities/Utility'
View = require 'famous/core/View'

# Pegg
AppStateStore = require 'stores/AppStateStore'
Constants = require 'constants/PeggConstants'
ProfileActivityItemView = require 'views/ProfileActivityItemView'
ProfileHeaderView = require 'views/ProfileHeaderView'
UserActions = require 'actions/UserActions'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'


class ProfileView extends View
  @DEFAULT_OPTIONS:
    headerHeight: 50,
    profileContainerWidth: Utils.getViewportWidth()
    profileContainerHeight: Utils.getViewportHeight()
    profileContainerRatio: 2/5
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight()
    transition:
      duration: 500
      curve: Easing.outExpo

  constructor: (options) ->
    super options

    # set profileContainerHeight based off headerHeight and ratio
    @.setOptions
      profileContainerHeight: (Utils.getViewportHeight() - @options.headerHeight) * @options.profileContainerRatio

    @init()
    @initListeners()

  initListeners: ->
    UserStore.on Constants.stores.CHANGE, @_loadUser
    UserStore.on Constants.stores.PROFILE_ACTIVITY_CHANGE, @_loadActivity

  init: ->
    
    @_initFilterBar()

    @mainMod = new Modifier
      align: [0, 0],
      origin: [0, 0]

    @profileHeader = new ProfileHeaderView
      avatarWidth: 150
      avatarHeight: 150
      width: @options.profileContainerWidth
      height: @options.profileContainerHeight
#      avatar: UserStore.getAvatar 'height=150&type=normal&width=150'
#      firstname: UserStore.getName 'first'

    @container = new ContainerSurface
      size: [@options.width, @options.height - @options.headerHeight]
      classes: ['profilepage']
      properties: {
        overflow: 'hidden'
      }

    @scrollview = new Scrollview
      direction: Utility.Direction.Y
      paginated: false

    @permanentRows = [@profileHeader, @prefBoardHeaderNode]
    @rows = [].concat(@permanentRows)

    # @scrollview.sequenceFrom(@rows)
    
    @mainNode = @add @mainMod
    @container.add @scrollview
#    @container.pipe @scrollview
    @mainNode.add @container

  _initFilterBar: () ->
    @prefBoardHeaderNode = new RenderNode
    
    @prefBoardHeaderButtons = []

    mod = new StateModifier
      size: [undefined, @options.headerHeight]

    headerBacking = new Surface
      size: [undefined, @options.headerHeight]
      classes: ['peggBoardHeader', 'peggBoardHeader__bg']

    @_addFilterBarButton 'Recent', () ->
      UserActions.filterPrefs 'recent'
    @_addFilterBarButton 'Popular', () ->
      UserActions.filterPrefs 'popular'
    @_addFilterBarButton 'Search', () ->
      UserActions.filterPrefs 'search'

    sequence = new SequentialLayout
      direction: Utility.Direction.X

    sequence.sequenceFrom @prefBoardHeaderButtons

    @prefBoardHeaderNode = @prefBoardHeaderNode.add mod
    @prefBoardHeaderNode.add headerBacking
    @prefBoardHeaderNode.add sequence


  _addFilterBarButton: (content, clickCallback, numOfButtons) ->
    content = content || ''
    clickCallback = clickCallback || (->)
    numOfButtons = numOfButtons || 3

    itemWidth = Utils.getViewportWidth() / numOfButtons
    itemHeight = @options.headerHeight

    surface = new Surface
      content: content
      size: [itemWidth, itemHeight]
      classes: ['peggBoardHeader', 'peggBoardHeader__button']
      properties: {
        textAlign: 'center'
        lineHeight: itemHeight + 'px'
      }

    surface.on 'click', clickCallback

    @prefBoardHeaderButtons.push surface

  _loadUser: =>
    @profileHeader.setAvatar UserStore.getAvatar 'height=150&type=normal&width=150'
    @profileHeader.setFirstname UserStore.getName 'first'

  _loadActivity: =>
    # remove all the images
    @rows = [].concat(@permanentRows)
    
    data = UserStore.getProfileActivity()
    if data?
      ## Initialize Rows
      for item in data
        row = new ProfileActivityItemView
          data: item
        row.pipe @scrollview
        @rows.push row

    @scrollview.sequenceFrom(@rows)

module.exports = ProfileView
