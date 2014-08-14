require './scss/profile.scss'

View = require 'famous/core/View'
RenderNode = require 'famous/core/RenderNode'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'
Transitionable = require 'famous/transitions/Transitionable'
Modifier = require 'famous/core/Modifier'
Scrollview = require 'famous/views/Scrollview'
Utility = require 'famous/utilities/Utility'
SequentialLayout = require 'famous/views/SequentialLayout'

Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'

Utils = require 'lib/Utils'
ProfileHeaderView = require 'views/ProfileHeaderView'
PrefBoardRowView = require 'views/PrefBoardRowView'
PrefBoardView = require 'views/PrefBoardView'

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
    UserStore.on Constants.stores.LOGIN_CHANGE, @_loadUser.bind(@)
    UserStore.on Constants.stores.PREF_IMAGES_CHANGE, @_loadImages.bind(@)

  init: ->
    
    @_initPrefBoardHeader()

    @mainMod = new Modifier
      align: [0, 0],
      origin: [0, 0]

    @profileHeader = new ProfileHeaderView
      width: @options.profileContainerWidth
      height: @options.profileContainerHeight
      avatar: UserStore.getAvatar 'height=300&type=normal&width=300'
      firstname: UserStore.getName 'first'

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
    @container.pipe @scrollview
    @mainNode.add @container

  _initPrefBoardHeader: () ->
    @prefBoardHeaderNode = new RenderNode
    
    @prefBoardHeaderButtons = []

    mod = new StateModifier
      size: [undefined, @options.headerHeight]

    headerBacking = new Surface
      size: [undefined, @options.headerHeight]
      classes: ['peggBoardHeader', 'peggBoardHeader__bg']

    @_addPrefBoardHeaderButton('one')
    @_addPrefBoardHeaderButton('two')
    @_addPrefBoardHeaderButton('three')

    sequence = new SequentialLayout
      direction: Utility.Direction.X

    sequence.sequenceFrom @prefBoardHeaderButtons

    @prefBoardHeaderNode = @prefBoardHeaderNode.add mod
    @prefBoardHeaderNode.add headerBacking
    @prefBoardHeaderNode.add sequence


  _addPrefBoardHeaderButton: (content, clickCallback, numOfButtons) ->
    content = content || ''
    clickCallback = clickCallback || () ->
      console.log @
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
    @profileHeader.setAvatar UserStore.getAvatar 'height=300&type=normal&width=300'
    @name.setFirstname UserStore.getName('first')

  _loadImages: =>
    # @prefBoard.loadImages UserStore.getPrefImages()
    # @rows = @rows.slice(0,2)

    # remove all the images
    @rows = [].concat(@permanentRows)
    console.log '_loadImages', @rows
    
    data = UserStore.getPrefImages()
    cols = 3

    ## Initialize Rows
    while data.length
      set = data.splice 0, cols
      row = new PrefBoardRowView
        width: @options.width - 5
        columns: cols
        gutter: 5
        data: set

      row.pipe @scrollview
      @rows.push row

    console.log '_loadImages2', @rows
    @scrollview.sequenceFrom(@rows)

module.exports = ProfileView
