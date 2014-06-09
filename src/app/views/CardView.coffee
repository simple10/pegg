# CardView
#
# Flip between front and back side of card.

require './scss/card.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'
PlayActions = require 'actions/PlayActions'
_ = require('Parse')._

ImageUploadView = require 'views/ImageUploadView'

class CardView extends View
  @DEFAULT_OPTIONS:
    width: 290
    height: 350
    depth: -5
    borderRadius: 10
    duration: 500
    easing: Easing.outCubic

  constructor: (card, options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @card = card
    @init()

  init: () ->
    width = @options.width
    height = @options.height
    depth = @options.depth

    @state = new StateModifier
    @mainNode = @add @state

    ## Front Card
    front = new Surface
      size: [ width, height ]
      classes: ['card__front']
      properties:
        borderRadius: "#{@options.borderRadius}px"
    modifier = new Modifier
      transform: Transform.translate 0, 0, depth/2
    front.on 'click', @showOptions
    @mainNode.add(modifier).add front

    ## Back Card
    back = new Surface
      size: [ width, height ]
      classes: ['card__back']
      properties:
        borderRadius: "#{@options.borderRadius}px"
        padding: "10px"
    modifier = new Modifier
      transform: Transform.multiply(
        Transform.translate(0, 0, -depth/2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    back.on "click", =>
      PlayActions.answer 'card', 'choice'
    @mainNode.add(modifier).add back

    ## Question
    @question = new Surface
      size: [ width, height ]
      classes: ['card__front__question']
      content: @card.get "title"
    @qModifier = new StateModifier
      transform: Transform.translate 0, height/2 + -100, depth/2 + 2
    @question.on 'click', @showOptions
    @mainNode.add(@qModifier).add @question

    ## Options
    option1 = new Surface
      size: [ width, height/6 ]
      classes: ['card__front__option']
      content: @card.get('caption1')
    @o1Modifier = new StateModifier
      opacity: 0
      transform: Transform.translate 0, height/6, depth/2
    option1.on 'click', =>
      @pickAnswer 1
    @mainNode.add(@o1Modifier).add option1

    option2 = new Surface
      size: [ width, height/6 ]
      classes: ['card__front__option']
      content: @card.get('caption2')
    @o2Modifier = new StateModifier
      opacity: 0
      transform: Transform.translate 0, height/6, depth/2
    option2.on 'click', =>
      @pickAnswer 2
    @mainNode.add(@o2Modifier).add option2

    option3 = new Surface
      size: [ width, height/6 ]
      classes: ['card__front__option']
      content: @card.get('caption3')
    @o3Modifier = new StateModifier
      opacity: 0
      transform: Transform.translate 0, height/6, depth/2
    option3.on 'click', =>
      @pickAnswer 3
    @mainNode.add(@o3Modifier).add option3

    option4 = new Surface
      size: [ width, height/6 ]
      content: "<input type='text' name='newOption' class='card__front__input' style='width: #{@options.width-100}px' placeholder='Type your own...'>"
      properties:
        width: @options.width
    @o4Modifier = new StateModifier
      opacity: 0
      transform: Transform.translate 0, height/6, depth/2
#    option4.on 'click', =>
#      @pickAnswer 3
    @mainNode.add(@o4Modifier).add option4

    ## Image
    @image = new ImageSurface
      size: [@options.width - 40, null]
      classes: ['card__back__image']
      content: @card.get('image1')
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{@options.height - 100}px"
    @image.on "click", =>
      @flip()
    @imageModifier = new StateModifier
      align: [0.5,0.5]
      transform: Transform.multiply(
        Transform.translate(0, -100, -@options.depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @text = new Surface
      size: [@options.width - 40, null]
      classes: ['card__back__text']
      content: @card.get('caption1')
    @textModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -150, -@options.depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(@imageModifier).add @image
    @mainNode.add(@textModifier).add @text


  showOptions: =>
    #@question.setClasses(['card__front__question--small'])
    @qModifier.setTransform(
      Transform.translate 0, 20, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    @o1Modifier.setOpacity 1
    @o1Modifier.setTransform(
      Transform.translate 0,  10, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    @o2Modifier.setOpacity 1
    @o2Modifier.setTransform(
      Transform.translate 0, 50, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    @o3Modifier.setOpacity 1
    @o3Modifier.setTransform(
      Transform.translate 0, 90, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    @o4Modifier.setOpacity 1
    @o4Modifier.setTransform(
      Transform.translate 0, 150, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )

  pickAnswer: (choice) =>
    PlayActions.answer 'card', 'choice'
    @image.setContent @card.get('image' + choice)
    @text.setContent @card.get('caption' + choice)
    #uploadImage = new ImageUploadView
    #@mainNode.add(imageModifier).add uploadImage
    @flip()

  flip: (side) =>
    @state.halt()
    @currentSide ?= 0
    if side is 0 or side is 1
      @currentSide = side
    else
      @currentSide = if @currentSide is 1 then 0 else 1

    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      duration : @options.duration
      curve: @options.easing
    )


module.exports = CardView


