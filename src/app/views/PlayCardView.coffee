require './scss/play.scss'

# Famo.us
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Easing = require 'famous/src/transitions/Easing'
GenericSync = require 'famous/src/inputs/GenericSync'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier = require 'famous/src/core/Modifier'
MouseSync = require 'famous/src/inputs/MouseSync'
RenderController = require 'famous/src/views/RenderController'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Timer = require 'famous/src/utilities/Timer'
TouchSync = require 'famous/src/inputs/TouchSync'
Transform = require 'famous/src/core/Transform'
Transitionable = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
Constants = require 'constants/PeggConstants'
InputView = require 'views/InputView'
LayoutManager = require 'views/layouts/LayoutManager'
PlayActions = require 'actions/PlayActions'
PlayNavView = require 'views/PlayNavView'
PlayStore = require 'stores/PlayStore'
SingleCardStore = require 'stores/SingleCardStore'
AppStateStore = require 'stores/AppStateStore'
UserStore = require 'stores/UserStore'
CardStore = require 'stores/CardStore'
Utils = require 'lib/Utils'

class PlayCardView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    @_viewportHeight = Utils.getViewportHeight()
    @_viewportWidth = Utils.getViewportWidth()

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXAlign = new Transitionable(0)

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PAGE_CHANGE, @loadPlay
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    CardStore.on Constants.stores.CARD_FAIL, @cardFail
    CardStore.on Constants.stores.CARD_WIN, @cardWin
    SingleCardStore.on Constants.stores.CARD_WIN, @cardWin
    SingleCardStore.on Constants.stores.CARD_CHANGE, @loadSingleCard
    SingleCardStore.on Constants.stores.REQUIRE_LOGIN, @requireLogin
#    AppStateStore.on Constants.stores.MENU_CHANGE, @

    @cardView.on 'comment', =>
      @collapseComments()
    @cardView.on 'pegg', (payload) =>
      PlayActions.pegg payload.peggeeId, payload.id, payload.choiceId, payload.answerId
    @cardView.on 'pref', (payload) =>
      PlayActions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
    @cardView.on 'plug', (payload) =>
      PlayActions.plug payload.id, payload.full, payload.thumb
    @cardView.pipe @

  initViews: ->
    ## CARD ##
    @cardView = new CardView
    @cardViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        [@layout.cards.align[0], @layout.cards.align[1] + yAlign]
      origin: @layout.cards.origin
    @add(@cardViewMod).add @cardView

    ## PLAY NAV ##
    @playNavView = new PlayNavView
    @add @playNavView
    @playNavView.hideRightArrow()

    ## COMMENTS ##
    @commentsView = new CommentsView
    @newComment = new InputView
      size: @layout.newComment.size
      placeholder: "Enter a comment..."
      align: @layout.newComment.states[1].align
      origin: @layout.newComment.origin
    @newCommentMod = new StateModifier
      align: @layout.newComment.align
      origin: @layout.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.clear()
      @saveComment comment

    @numComments = new Surface
      size: @layout.numComments.size
      content: "x comments..."
      classes: ['comments__text', 'comments__num']
    @numCommentsMod = new StateModifier
      align: @layout.numComments.align
      origin: @layout.numComments.origin
    @add(@numCommentsMod).add @numComments
    @numComments.on 'click', =>
      @expandComments()
    @hideComments()

    @rc = new RenderController
      inTransition:  { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    @rc.hide(@commentsView)
    @rcMod = new StateModifier
      align: @layout.comments.align
      origin: @layout.comments.origin
    @add(@rcMod).add @rc


    ## POINTS ##
    @points = new Surface
      size: @layout.points.size
      classes: @layout.points.classes
    @pointsMod = new Modifier
      align: @layout.points.align
      origin: @layout.points.origin
      transform: @layout.points.transform
    @add(@pointsMod).add @points

  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    minVelocity = 0.5
    minDelta = 100

    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'card:flipped', (card) =>
      @collapseComments() if @_commentsIsExpanded

    @_eventInput.pipe @sync

    isMovingY = false
    startPos = 0

    @sync.on 'start', (data) =>
      startPos = @cardYPos.get()

    @sync.on 'update', ((data) ->
      dy = data.delta[1]
      if !isMovingY
        if Math.abs(dy) > 0
          isMovingY = true
      if isMovingY
        currentPosition = @cardYPos.get()
        #        console.log 'currentPosition', currentPosition
        # calculate the max Y offset to prevent the user from being able
        # to drag the card past this point
        max = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
        pos = Math.min Math.abs(max), Math.abs(currentPosition + dy)
        @cardYPos.set(-pos)
    ).bind(@)

    @sync.on 'end', ((data) ->
      # figure out if we need to show/hide the comments if moving along the Y axis
      if isMovingY
        # retrieve the Y velocity
        velocity = data.velocity[1]
        # calculate the total position change
        delta = startPos - @cardYPos.get()
        # swiping/dragging up and crossed pos and vel threshold
        if delta > minDelta && Math.abs(velocity) > minVelocity
          @expandComments()
          # swiping/dragging down and crossed pos and vel threshold
        else if delta < -minDelta && Math.abs(velocity) > minVelocity
          @collapseComments()
          # otherwise threshold not met, so return to original position
        else if delta
          if !@_commentsIsExpanded
            @collapseComments()
          else
            @expandComments()
      # reset axis movement flags
      isMovingY = false
    ).bind(@)

  loadSingleCard: =>
    @playNavView.showSingleCardNav()
    @_load SingleCardStore.getCard()
# MAYBE: set options??
#   @playNavView.setOptions {
#     'cardType': card.type
#   }
#    if referrer?
#      @playNavView.showLeftArrow()
    @showComments()
#    else
#      @playNavView.hideLeftArrow()
#      @hideComments()

  _load: (card) =>
    @card = card
    @cardView.loadCard @card
    @loadComments()

  loadPlay: =>
    page = PlayStore.getCurrentPage()
    if page.type is 'card'
      @playNavView.showPlayNav()
      @_load page.card

  loadComments: =>
    @commentsView.load @card.comments
    @numComments.setContent "#{@commentsView.getCount()} comments."

  nextPage: =>
    PlayActions.nextPage()
    @playNavView.hideRightArrow()
    @hideComments()

  prevPage: =>
    PlayActions.prevPage()

  cardPref: =>
    @showComments()
    @playNavView.showRightArrow()

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent PlayStore.getMessage('fail')

  cardWin: (points) =>
    @showPoints points
    @showComments()
    debugger
    @playNavView.showRightArrow()

  showPoints: (points) =>
    console.log "points: #{points}"
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showComments: =>
    Utils.animate @numCommentsMod, @layout.numComments.states[0]
#    @rc.show(@commentsView)

  hideComments: =>
    Utils.animate @numCommentsMod, @layout.numComments.states[1]
#    @newComment.setAlign @layout.newComment.states[0].align
#    @rc.hide(@commentsView)

  saveComment: (comment) ->
    PlayActions.comment comment, @card.id, @card.peggeeId
    newComment =
      userImg: UserStore.getAvatar 'type=square'
      text: comment
    if @card.comments? and @card.comments.length > 0
      @card.comments.unshift newComment
    else
      @card.comments = [newComment]
    @loadComments()

  collapseComments: =>
    @rc.hide(@commentsView)
    @playNavView.showNav()
    # slide the cards down to their starting position
    @cardYPos.set(0, @layout.cards.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @numCommentsMod, @layout.numComments.states[0]
    @._commentsIsExpanded = false
    @newComment.setAlign @layout.newComment.states[0].align

  expandComments: =>
    @rc.show(@commentsView)
    @playNavView.hideNav()
    maxCardYPos = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @layout.cards.states[1].transition)
    # slide the comments up
    Utils.animate @numCommentsMod, @layout.numComments.states[1]
    @._commentsIsExpanded = true
    @newComment.setAlign @layout.newComment.states[1].align

  requireLogin: =>
    MessageActions.show 'app__login_required'

  _translateToAlign: (delta, axis) =>
    if axis is 'Y'
      delta / @_viewportHeight
    else if axis is 'X'
      delta / @_viewportWidth
    else
      null

module.exports = PlayCardView
