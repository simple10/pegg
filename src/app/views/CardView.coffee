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

    width = @options.width
    height = @options.height
    depth = @options.depth
    @initCard width, height, depth
    @initQuestion width, height, depth
    @initChoices width, Math.floor(height/6), depth/2
    @initAnswer width, height, depth

  initCard: (width, height, depth) ->
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
    @mainNode.add(modifier).add back

  initQuestion: (width, height, depth) ->
    @question = new Surface
      size: [ width, height ]
      classes: ['card__front__question']
      content: @card.get "title"
    @qModifier = new StateModifier
      transform: Transform.translate 0, height/2 + -100, depth/2 + 2
    @question.on 'click', @showOptions
    @mainNode.add(@qModifier).add @question

  initChoices: (width, height, depth) ->
    for i in [1..3]
      option = new Surface
        size: [ width, height ]
        classes: ['card__front__option']
        content: "
              <div class='outerContainer' style='width: #{width-40}px; height: #{height}px'>
                <div class='innerContainer'>
                 #{@card.get("caption#{i}")}
                </div>
              </div>"
      @["o#{i}Modifier"] = new StateModifier
        opacity: 0
        transform: Transform.translate 0, height, depth
      option.on 'click', ((i) ->
        @pickAnswer i
      ).bind @, i
      @mainNode.add(@["o#{i}Modifier"]).add option

    option4 = new Surface
      size: [ width, height ]
      content: "<input type='text' name='newOption' class='card__front__input' style='width: #{@options.width-100}px' placeholder='Type your own...'>"
      properties:
        width: @options.width
    @o4Modifier = new StateModifier
      opacity: 0
      transform: Transform.translate 0, height, depth
    @mainNode.add(@o4Modifier).add option4

  initAnswer: (width, height, depth) ->
    @image = new ImageSurface
      size: [width - 40, null]
      classes: ['card__back__image']
      #content: @card.get('image1')
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{height - 100}px"
    @image.on "click", =>
      @image.setContent ""
      @flip()
    @imageModifier = new StateModifier
      align: [0.5,0.5]
      transform: Transform.multiply(
        Transform.translate(0, -100, -depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @text = new Surface
      size: [width - 40, null]
      classes: ['card__back__text']
      content: @card.get('caption1')
    @textModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -150, -depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(@imageModifier).add @image
    @mainNode.add(@textModifier).add @text


  showOptions: =>
    PlayActions.pick @card.id
    @question.setClasses(['card__front__question--small'])
    @qModifier.setTransform(
      Transform.translate 0, 20, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    for i in [1..4]
      @["o#{i}Modifier"].setOpacity 1
      @["o#{i}Modifier"].setTransform(
        Transform.translate 0, 50*(i-1), @options.depth/2 + 2
        duration : @options.duration
        curve: @options.easing
      )

  pickAnswer: (choice) =>
    PlayActions.answer choice
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


