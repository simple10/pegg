require './scss/card.scss'
_ = require('Parse')._

# Famo.us
Easing = require 'famous/transitions/Easing'
GenericSync = require 'famous/inputs/GenericSync'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
MouseSync = require 'famous/inputs/MouseSync'
RenderController = require 'famous/views/RenderController'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
Timer = require 'famous/utilities/Timer'
TouchSync = require 'famous/inputs/TouchSync'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
View = require 'famous/core/View'
RenderController = require 'famous/views/RenderController'

# Pegg
ChoicesView = require 'views/ChoicesView'
Constants = require 'constants/PeggConstants'
ImagePickView = require 'views/ImagePickView'
LayoutManager = require 'views/layouts/LayoutManager'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'

class CardView extends View

  constructor: (options) ->
#    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'CardView'

    @initCard()
    @initQuestion()
    @initChoices()
    @initAnswer()
    @initGestures()

  initCard: ->
    @state = new StateModifier
      origin: @layout.card.origin
#      align: @layout.card.align
    @mainNode = @add @state
    ## Front Card
    @front = new ImageSurface
      size: @layout.card.size
      content: 'images/Card.svg'
    frontMod = new Modifier
      transform: @layout.card.front.transform
    @mainNode.add(frontMod).add @front
    ## Back Card
    @back = new ImageSurface
      size: @layout.card.size
      content: 'images/Card.svg'
    backMod = new Modifier
      transform: @layout.card.back.transform
    @mainNode.add(backMod).add @back

  initQuestion: ->
    @frontProfilePic = new ImageSurface
      size: @layout.profilePic.size
      classes: @layout.profilePic.big.classes
      properties:
        borderRadius: "#{@layout.profilePic.size[0]}px"
    @frontProfilePicMod = new StateModifier
      origin: @layout.profilePic.big.origin
      align: @layout.profilePic.big.align
      transform: @layout.profilePic.big.transform
    @mainNode.add(@frontProfilePicMod).add @frontProfilePic

    @frontQuestion = new Surface
      size: @layout.question.big.size
      classes: @layout.question.big.classes
    @frontQuestionMod = new StateModifier
      origin: @layout.question.big.origin
      align: @layout.question.big.align
      transform: @layout.question.big.transform
    @mainNode.add(@frontQuestionMod).add @frontQuestion

  initChoices: ->
    @choicesView = new ChoicesView @layout.choices
    @choicesMod = new StateModifier
      origin: @layout.choices.origin
      align: @layout.choices.align
      transform: @layout.choices.show

    @rc = new RenderController
      inTransition:  { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    #    @rc.inTransformFrom -> Transform.translate 0, Utils.getViewportHeight(), 0
    #    @rc.outTransformFrom -> Transform.translate 0, Utils.getViewportHeight(), 0
    @mainNode.add(@choicesMod).add @rc
    @choiceShowing = false
    @choicesView.hideChoices()

  initAnswer: ->
    @backImage = new ImageSurface
      size: @layout.answerImage.size
      classes: @layout.answerImage.classes
      properties:
        borderRadius: "#{@layout.answerImage.borderRadius}px"
        maxHeight: "#{@layout.answerImage.maxHeight}px"
#        maxWidth: "#{@layout.answerImage.maxWidth}px"
    @backImage.on 'click', =>
      #TODO Expand image when
#      @toggleZoom()
    @backImageModifier = new StateModifier
      transform: @layout.answerImage.transform
    @mainNode.add(@backImageModifier).add @backImage

    @backText = new Surface
      size: @layout.answerText.size
      classes: @layout.answerText.classes
    @backTextModifier = new StateModifier
      transform: @layout.answerText.transform
    @mainNode.add(@backTextModifier).add @backText

    @addImageButton = new ImageSurface
      size: @layout.addImage.size
      content: @layout.addImage.content
      classes: @layout.addImage.classes
    addImageMod = new StateModifier
      origin: @layout.addImage.origin
      align: @layout.addImage.align
      transform: @layout.addImage.transform
    @addImageRenderer = new RenderController
    imagePickView = new ImagePickView()
    @addImageButton.on 'click', =>
      imagePickView.pick( (results) =>
        console.log JSON.stringify(results)
        @backImage.setContent results.fullS3
        debugger
        @_eventOutput.emit 'plug',
          id: @card.id
          full: results.key
          thumb: results.thumb.key
      )
    @mainNode.add imagePickView
    @mainNode.add(addImageMod).add(@addImageRenderer)

  # Doesn't respond to gestures, just makes sure that the events
  # get to the right place
  initGestures: ->
    @front.pipe @_eventOutput
    @frontProfilePic.pipe @_eventOutput
    @frontQuestion.pipe @_eventOutput
    @back.pipe @_eventOutput
    @backImage.pipe @_eventOutput
    @backText.pipe @_eventOutput

  clearCard: () ->
    # clear content
    @backImage.setContent ""
    @backText.setContent ""
    @choicesView.clearChoices()
    @frontProfilePic.setContent ""
    @frontQuestion.setContent ""
    @addImageRenderer.hide @addImageButton

    # clear event listeners
    @back.removeListener 'click', @flip
    @backImage.removeListener 'click', @flip
    @backText.removeListener 'click', @flip
    @front.removeListener 'click', @flip
    @front.removeListener 'click', @toggleChoices
    @frontProfilePic.removeListener 'click', @flip
    @frontProfilePic.removeListener 'click', @toggleChoices
    @frontQuestion.removeListener 'click', @flip
    @frontQuestion.removeListener 'click', @toggleChoices

    # reset card elements positioning
    @toggleChoices() if not @choiceShowing

  loadCard: (card, type) ->
    @clearCard()
    @card = card

    if type is 'review' or type is 'deny'
      @front.on 'click', @flip
      @back.on 'click', @flip
      @frontProfilePic.on 'click', @flip
      @frontQuestion.on 'click', @flip
      @backImage.on 'click', @flip
      @backText.on 'click', @flip

    if type is 'review'
      @loadAnswer @card.plug, @card.answer.get 'text'
      @frontProfilePic.setContent "#{@card.pic}/?height=100&type=normal&width=100"
      if card.peggee is UserStore.getUser().id
        @addImageRenderer.show @addImageButton
    else if type is 'deny'
      @frontProfilePic.setContent "#{@card.pic}"
      @loadAnswer @card.plug, null
    else
      @front.on 'click', @toggleChoices
      @back.on 'click', =>
        @_eventOutput.emit 'comment', @
      @frontProfilePic.on 'click', @toggleChoices
      @frontQuestion.on 'click', @toggleChoices
      @frontProfilePic.setContent "#{@card.pic}/?height=100&type=normal&width=100"

    if @card.question.length > 90
      @layout.question.classes = ["#{@layout.question.big.classes}--medium"]
    @frontQuestion.setContent @card.question
    @flip() if @currentSide is 1

    @choicesView.load @card.choices
    @choicesView.on 'choice', ((i) ->
      @pickAnswer i
    ).bind @


  toggleChoices: =>
    if @choiceShowing
      @frontQuestion.setClasses @layout.question.big.classes
      @frontQuestion.setSize @layout.question.big.size
      Utils.animate(@frontQuestionMod, @layout.question.big)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.big)

      @rc.hide(@choicesView)
      @choicesView.hideChoices()
#      @choicesMod.setTransform Transform.translate(0, 0, -3)
      @_eventOutput.emit 'choices:hidden', @
      @choiceShowing = false

    else
      @frontQuestion.setClasses @layout.question.small.classes
      @frontQuestion.setSize @layout.question.small.size
      Utils.animate(@frontQuestionMod, @layout.question.small)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.small)

      @rc.show(@choicesView)
      @choicesView.showChoices()
#      @choicesMod.setTransform Transform.translate(0, 0, 5)
      @_eventOutput.emit 'choices:showing', @
      @choiceShowing = true


  pickAnswer: (i) =>
    choice = @card.choices[i]
    if @card.peggee?
      @_eventOutput.emit 'pegg',
        peggee: @card.peggee
        id: @id
        choiceId: choice.id
        answerId: @card.answer.id
      if @card.answer.id is choice.id
        @choiceWin choice, i
      else
        @choiceFail choice, i
    else
      @_eventOutput.emit 'pref',
        id: @card.id
        choiceId: choice.id
        plug: choice.plug
        thumb: choice.thumb
      @loadAnswer choice.plug.S3, choice.text
      @addImageRenderer.show @addImageButton
      @flip()

  choiceFail: (choice, i) =>
    @choicesView.fail choice, i

  choiceWin: (choice, i) =>
    @toggleChoices()
    @choicesView.win choice, i
    @choicesView.on 'choice:doneShowingStatus', () =>
      @loadAnswer @card.plug, choice.text
      @flip()

  flip: =>
    @currentSide = if @currentSide is 1 then 0 else 1
    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      @layout.card.transition
    )
#    hideShow = if @currentSide is 1 then @layout.card.front.hide else @layout.card.front.show
#    @frontProfilePicMod.setTransform hideShow
#    @frontQuestionMod.setTransform hideShow
#    @choicesMod.setTransform hideShow
    @_eventOutput.emit 'card:flipped', @

  loadAnswer: (image, text) =>
    @backImage.setContent image
    @backText.setContent text

  toggleZoom: =>
    if @big
      @big = false
      @backImage.setSize @layout.answerPic.size
    else
      @big = true
      @backImage.setSize [Utils.getViewportWidth(), Utils.getViewportHeight()]


module.exports = CardView
