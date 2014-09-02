require './scss/card.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'

_ = require('Parse')._
PlayActions = require 'actions/PlayActions'
ImagePickView = require 'views/ImagePickView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
ChoicesView = require 'views/ChoicesView'
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'

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

    if @options.type is 'review'
      @front.on 'click', @flip
      @back.on 'click', @flip
    else
      @front.on 'click', @toggleChoices
      @back.on 'click', =>
        @_eventOutput.emit 'comment', @
        #@flip()

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

    if @options.type is 'review'
      @frontProfilePic.on 'click', @flip
      @frontQuestion.on 'click', @flip
    else
      @frontProfilePic.on 'click', @toggleChoices
      @frontQuestion.on 'click', @toggleChoices

  initChoices: ->
    @showChoices = true
    @choicesView = new ChoicesView @layout.choices
    @choicesMod = new StateModifier
      origin: @layout.choices.origin
      align: @layout.choices.align
    @mainNode.add(@choicesMod).add @choicesView
    @choicesMod.setTransform @layout.choices.hide

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

    if @options.type isnt 'review'
      addImageButton = new ImageSurface
        size: @layout.addImage.size
        content: @layout.addImage.content
        classes: @layout.addImage.classes
      @addImageModifier = new StateModifier
        transform: @layout.addImage.show
      imagePickView = new ImagePickView()
      addImageButton.on 'click', =>
        imagePickView.pick( (results) =>
          console.log JSON.stringify(results)
          @backImage.setContent results[0].url
          PlayActions.plug @id, results[0].url
        )
      @mainNode.add imagePickView
      @mainNode.add(@addImageModifier).add addImageButton
    else
      @backImage.on 'click', @flip
      @backText.on 'click', @flip

  # Doesn't respond to gestures, just makes sure that the events
  # get to the right place
  initGestures: ->
    @front.pipe @_eventOutput
    @frontProfilePic.pipe @_eventOutput
    @frontQuestion.pipe @_eventOutput
    @back.pipe @_eventOutput
    @backImage.pipe @_eventOutput
    @backText.pipe @_eventOutput

  loadCard: (id, card) ->
    @card = card
    @id = id
    if @card.question.length > 90
      @layout.question.classes = ["#{@layout.question.big.classes}--medium"]
    @frontQuestion.setContent @card.question
    @frontProfilePic.setContent "#{@card.pic}/?height=200&type=normal&width=200"
    if @options.type is 'review'
      @loadAnswer @card.plug, @card.answer.get 'text'

  loadChoices: (cardId) ->
    @choicesView.load cardId
    @choicesView.on 'choice', ((i) ->
      @pickAnswer i
    ).bind @

  toggleChoices: =>
    if @showChoices
      @frontQuestion.setClasses @layout.question.small.classes
      @frontQuestion.setSize @layout.question.small.size
      Utils.animate(@frontQuestionMod, @layout.question.small)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.small)

      @choicesMod.setTransform @layout.choices.show
      @choicesView.showChoices()
      @showChoices = false
      @_eventOutput.emit 'choices:showing', @
    else
      @frontQuestion.setClasses @layout.question.big.classes
      @frontQuestion.setSize @layout.question.big.size
      Utils.animate(@frontQuestionMod, @layout.question.big)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.big)

      @choicesMod.setTransform @layout.choices.hide
      @choicesView.hideChoices()
      @showChoices = true
      @_eventOutput.emit 'choices:hidden', @

  pickAnswer: (i) =>
    choice = @card.choices[i]
    if @card.peggee?
      PlayActions.pegg @card.peggee, @id, choice.id, @card.answer.id
      if @card.answer.id is choice.id
        @choiceWin choice, i
      else
        @choiceFail choice, i
      @addImageModifier.setTransform @layout.addImage.hide
    else
      PlayActions.pref @id, choice.id, choice.image
      @loadAnswer choice.image, choice.text
      @flip choice

  choiceFail: (choice, i) =>
    @choicesView.fail choice, i

  choiceWin: (choice, i) =>
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
