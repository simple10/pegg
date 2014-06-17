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
Timer = require 'famous/utilities/Timer'
ChoicesView = require 'views/ChoicesView'

_ = require('Parse')._

ImageUploadView = require 'views/ImageUploadView'

class CardView extends View
  @DEFAULT_OPTIONS:
    width: window.innerHeight/2
    height: window.innerHeight-200
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
    front = new ImageSurface
      size: [ width, height ]
      content: "images/Card_White.png"

    #front = new Surface
    #  size: [ width, height ]
    #  classes: ['card__front']
    #  properties:
    #    borderRadius: "#{@options.borderRadius}px"
    modifier = new Modifier
      transform: Transform.translate 0, 0, depth/2
    front.on 'click', @showChoices
    @mainNode.add(modifier).add front

    ## Back Card
    back = new ImageSurface
      size: [ width, height ]
      content: "images/Card_Blue.png"

    #back = new Surface
    #  size: [ width, height ]
    #  classes: ['card__back']
    #  properties:
    #    borderRadius: "#{@options.borderRadius}px"
    #    padding: "10px"
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
    @question.on 'click', @showChoices
    @mainNode.add(@qModifier).add @question

  initChoices: (width, height, depth) ->
    @choices =[]
    for i in [1..5]
      choice = new Surface
        size: [ width, height ]
        classes: ['card__front__option']
        content: "
              <div class='outerContainer' style='width: #{width-40}px; height: #{height}px'>
                <div class='innerContainer'>
                 #{@card.get("caption#{i}")}
                </div>
              </div>"
      choice.on 'click', ((i) ->
        @pickAnswer i
      ).bind @, i
      @choices.push choice

    choices = new ChoicesView
    choices.load @choices
    @choicesMod = new StateModifier
    @mainNode.add(@choicesMod).add choices
    @choicesMod.setTransform Transform.translate(0,0,-10)

    newChoice = new Surface
      size: [ width, height ]
      content: "<input type='text' name='newOption' class='card__front__input' style='width: #{width - 60}px' placeholder='Type your own...'>"
      properties:
        width: @options.width
    @newChoiceModifier = new StateModifier
      opacity: 0
      origin: [0.5,1.4]
      align: [0.5, 1]
    @mainNode.add(@newChoiceModifier).add newChoice

  initAnswer: (width, height, depth) ->
    @image = new ImageSurface
      size: [width - 40, null]
      classes: ['card__back__image']
      #content: @card.get('image1')
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{height - 100}px"
    @image.on "click", =>
      #@toggleImage
      @image.setContent ""
      @newChoiceModifier.setTransform Transform.translate(0,0,-10)
      @newChoiceModifier.setOpacity 0
      @flip()
    @imageModifier = new StateModifier
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


  toggleImage: =>
    if @big
      @big = false
      @image.setSize [@options.width, @options.height]
    else
      @big = true
      @image.setSize [window.innerWidth, window.innerHeight]

  showChoices: =>
    PlayActions.pick @card.id
    @question.setClasses(['card__front__question--small'])
    @qModifier.setTransform(
      Transform.translate 0, 20, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )

    @newChoiceModifier.setOpacity 1

    @choicesMod.setTransform Transform.translate 0, 50, 0

  hideChoices: =>
    @qModifier.setTransform(
      Transform.translate 0, @options.height/2 + -100, @options.depth/2 + 2
      duration : @options.duration
      curve: @options.easing
    )
    @choicesMod.setOpacity 0
    @question.on 'click', @showChoices


  pickAnswer: (choice) =>
    PlayActions.answer choice
    Timer.after ( =>
      @image.setContent @card.get('image' + choice)
    ), 20

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
