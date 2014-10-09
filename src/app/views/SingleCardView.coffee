require './scss/play.scss'

View = require 'famous/src/core/View'
Modifier = require 'famous/src/core/Modifier'
StateModifier = require 'famous/src/modifiers/StateModifier'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Utility = require 'famous/src/utilities/Utility'
Surface = require 'famous/src/core/Surface'
Transform = require 'famous/src/core/Transform'
Transitionable = require 'famous/src/transitions/Transitionable'
GenericSync = require 'famous/src/inputs/GenericSync'
MouseSync = require 'famous/src/inputs/MouseSync'
TouchSync = require 'famous/src/inputs/TouchSync'
Timer = require 'famous/src/utilities/Timer'

Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
SingleCardActions = require 'actions/SingleCardActions'
NavActions = require 'actions/NavActions'
SingleCardStore = require 'stores/SingleCardStore'
CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
InputView = require 'views/InputView'
SingleCardNavView = require 'views/SingleCardNavView'

LayoutManager = require 'views/layouts/LayoutManager'
StatusViewLayout = require 'views/layouts/mobile/StatusViewLayout'

class SingleCardView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'SingleCardView'

    @_viewportHeight = Utils.getViewportHeight()
    @_viewportWidth = Utils.getViewportWidth()

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    SingleCardStore.on Constants.stores.CARD_CHANGE, @loadCard
    SingleCardStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    SingleCardStore.on Constants.stores.CHOICES_CHANGE, (payload) =>
      @loadChoices payload.choices
    SingleCardStore.on Constants.stores.CARD_WIN, (points) =>
      @cardWin points
    SingleCardStore.on Constants.stores.REQUIRE_LOGIN, @requireLogin

  initViews: ->

    ## CARD ##
    @cardView = new CardView
    @cardViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        [@layout.card.align[0], @layout.card.align[1] + yAlign]
      origin: @layout.card.origin
    @add(@cardViewMod).add @cardView

    ## NAV ##
    @navView = new SingleCardNavView
    @navView._eventOutput.on 'back', =>
      referrer = SingleCardStore.getReferrer()
      NavActions.selectMenuItem referrer
    @add(@navView)

    ## COMMENTS ##
    @comments = new CommentsView
    @commentsMod = new StateModifier
      align: @layout.comments.align
      origin: @layout.comments.origin
      transform: Transform.translate null, null, -3
    @add(@commentsMod).add @comments
    
    @comments.on 'open', =>
      @expandComments()

    @newComment = new InputView
      size: @layout.newComment.size
      placeholder: 'Enter a comment...'
      align: @layout.newComment.states[1].align
      origin: @layout.newComment.origin
    @newCommentMod = new StateModifier
      align: @layout.newComment.align
      origin: @layout.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.setValue ''
      @saveComment comment

    @collapseComments()

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
        max = @layout.card.states[1].align[1] * Utils.getViewportHeight()
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

  loadCard: =>
    @collapseComments() if @._commentsIsExpanded
    card = SingleCardStore.getCard()

    @cardView.loadCard card.id, card, card.type
    @cardView.on 'comment', =>
      @collapseComments()
    @cardView.on 'pegg', (payload) =>
      SingleCardActions.pegg payload.peggeeId, payload.id, payload.choiceId, payload.answerId
    @cardView.on 'pref', (payload) =>
      SingleCardActions.pref payload.id, payload.choiceId, payload.image
    @cardView.on 'plug', (payload) =>
      SingleCardActions.plug payload.id, payload.full, payload.thumb
    @cardView.pipe @

    if SingleCardStore.getReferrer()?
      @navView.showNav()
      @navView.setOptions {
        'cardType': 'review'
        'message': SingleCardStore.getMessage()
      }
      @showComments()
    else
      @navView.hideNav()
      @hideComments()

  loadChoices: (choices) =>
    @cardView.loadChoices choices

  loadComments: =>
    @comments.load SingleCardStore.getComments()

  cardWin: (points) =>
    @showPoints points

  showPoints: (points) =>
    console.log "points: #{points}"
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showComments: =>
    Utils.animate @commentsMod, @layout.comments.states[1]

  hideComments: =>
    Utils.animate @commentsMod, @layout.comments.states[0]
    @newComment.setAlign @layout.newComment.states[0].align

  saveComment: (comment) ->
    SingleCardActions.comment(comment)

  collapseComments: =>
    # slide the cards down to their starting position
    @cardYPos.set(0, @layout.card.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @commentsMod, @layout.comments.states[1]
    @._commentsIsExpanded = false
    @newComment.setAlign @layout.newComment.states[0].align

  expandComments: =>
    maxCardYPos = @layout.card.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @layout.card.states[1].transition)
    # slide the comments up
    Utils.animate @commentsMod, @layout.comments.states[2]
    @._commentsIsExpanded = true
    @newComment.setAlign @layout.newComment.states[1].align

  requireLogin: =>
    alert 'Please log in to view this card'

  _translateToAlign: (delta, axis) =>
    if axis is 'Y'
      delta / @_viewportHeight
    else if axis is 'X'
      delta / @_viewportWidth
    else
      null

module.exports = SingleCardView
