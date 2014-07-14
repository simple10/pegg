require './scss/play.scss'

View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Scrollview = require 'famous/views/Scrollview'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
CardView = require 'views/CardView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
CommentsView = require 'views/CommentsView'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'
Utils = require 'lib/Utils'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'
StatusView = require 'views/StatusView'

class PlayView extends View

  constructor: (options) ->
    super options
    @initSurfaces()
    @initListeners()
    #@initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    PlayStore.on Constants.stores.CARD_FAIL, @cardFail
    PlayStore.on Constants.stores.CARD_WIN, @cardWin
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.STATUS_CHANGE, @loadStatus
    PlayStore.on Constants.stores.CHOICES_CHANGE, (cardId) =>
      @loadChoices cardId

  initSurfaces: ->
    ##  CARDS ##
    @cardScrollView = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 400
    @cardScrollViewMod = new StateModifier
      align: @options.cards.align
      origin: @options.cards.origin
    @add(@cardScrollViewMod).add @cardScrollView

    ## MESSAGE ##
    @message = new Surface
      size: @options.message.size
      content: 'Generic message'
      classes: @options.message.classes
    @messageMod = new StateModifier
      align: @options.message.align
      origin: @options.message.origin
      transform: @options.message.transform
    @add(@messageMod).add @message

    ## BUBBLE ##
    @bubble = new ImageSurface
      size: @options.bubble.size
      content: '/images/talk_rounded-square.png'
      classes: @options.bubble.classes
    @bubbleMod = new StateModifier
      align: @options.bubble.align
      origin: @options.bubble.origin
      transform: @options.bubble.transform
    @add(@bubbleMod).add @bubble

    ## UNICORN ##
    @unicorn = new ImageSurface
      size: @options.unicorn.size
      content: '/images/unicorn_talk.png'
      classes: @options.unicorn.classes
    @unicorn.on 'click', =>
      @nextCard()
    @unicornMod = new StateModifier
      align: @options.unicorn.align
      origin: @options.unicorn.origin
      transform: @options.unicorn.transform
    @add(@unicornMod).add @unicorn

    ## COMMENTS ##
    @comments = new CommentsView
    @commentsMod = new StateModifier
      align: @options.comments.align
      origin: @options.comments.origin
    @add(@commentsMod).add @comments
    @comments.on 'open', =>
      @expandComments()
    @newComment = new InputView {placeholder: "Enter a comment...", align: @options.newComment.states[1].align}
    @newCommentMod = new StateModifier
      align: @options.newComment.align
      origin: @options.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @saveComment comment

    ## STATUS ##
    @status = new StatusView
      size: @options.status.size
    @statusMod = new StateModifier
      align: @options.status.align
      origin: @options.status.origin
    @add(@statusMod).add @status


  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    @pos = 0
    #GenericSync.register MouseSync
    @sync = new GenericSync ['mouse', 'touch'], direction: GenericSync.DIRECTION_X
    @cardScrollView.pipe @sync

    @sync.on 'update', ((data) ->
      @pos += data.delta
      console.log "pos: #{@pos}"
      return
    ).bind(@)

    @sync.on 'end', ((data) ->
      alert "data: #{data}"
      return
    ).bind(@)

  loadCards: =>
    @cardViews = []
    @index = []
    @cardScrollView.sequenceFrom @cardViews
    i = 0
    for own cardId, cardObj of PlayStore.getCards()
      card = new CardView cardId, cardObj, size: [window.innerWidth, null]
      card.on 'comment', =>
        @collapseComments()
      card.pipe @cardScrollView
      @cardViews.push card
      @index[cardId] = i
      i++

    #@cardScrollView.on 'pageChange', =>
    #  @hideMessage()

    @showCards()

  loadChoices: (cardId) =>
    @cardViews[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  loadStatus: =>
    @showStatus()

  nextCard: =>
    @hideMessage()
    @hideComments()
    @cardScrollView.goToNextPage()
    PlayActions.nextCard()

  saveComment: (comment) ->
    PlayActions.comment(comment)

  cardPref: =>
    @message.setClasses ['card__message__pref']
    @message.setContent PlayStore.getMessage('pref')
    @showMessage()
    Utils.animate @commentsMod, @options.comments.states[1]

  cardFail: =>
    @message.setClasses ['card__message__fail']
    @message.setContent PlayStore.getMessage('fail')
    @showMessage()
    @fail++
    if @fail is 3
      @fail = 0
      Utils.animate @commentsMod, @options.comments.states[1]
    # TODO: if 3rd fail, show comments, disable options

  cardWin: =>
    @message.setClasses ['card__message__win']
    @message.setContent PlayStore.getMessage('win')
    @showMessage()
    Utils.animate @commentsMod, @options.comments.states[1]

  showMessage: =>
    Utils.animate @messageMod, @options.message.states[1]
    Utils.animate @bubbleMod, @options.bubble.states[1]
    Utils.animate @unicornMod, @options.unicorn.states[1]

  hideMessage: =>
    Utils.animate @messageMod, @options.message.states[0]
    Utils.animate @messageMod, @options.message.states[2]
    Utils.animate @bubbleMod, @options.bubble.states[0]
    Utils.animate @bubbleMod, @options.bubble.states[2]
    Utils.animate @unicornMod, @options.unicorn.states[0]
    Utils.animate @unicornMod, @options.unicorn.states[2]

  hideComments: =>
    Utils.animate @commentsMod, @options.comments.states[0]
    @newComment.setAlign @options.newComment.states[0].align

  collapseComments: =>
    Utils.animate @cardScrollViewMod, @options.cards.states[0]
    Utils.animate @commentsMod, @options.comments.states[1]
    @newComment.setAlign @options.newComment.states[0].align

  expandComments: =>
    Utils.animate @cardScrollViewMod, @options.cards.states[1]
    Utils.animate @commentsMod, @options.comments.states[2]
    @newComment.setAlign @options.newComment.states[1].align

  showCards: =>
    Utils.animate @cardScrollViewMod, @options.cards.states[0]
    Utils.animate @statusMod, @options.status.states[0]

  showStatus: =>
    @hideMessage()
    @newComment.setAlign @options.newComment.states[0].align
    Utils.animate @commentsMod, @options.comments.states[0]
    Utils.animate @cardScrollViewMod, @options.cards.states[2]
    Utils.animate @statusMod, @options.status.states[1]

module.exports = PlayView
