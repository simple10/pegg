require './scss/card.scss'

View = require 'famous/core/View'
Timer = require 'famous/utilities/Timer'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Flipper = require 'famous/views/Flipper'
PlayStore = require 'stores/PlayStore'

class ChoiceView extends View
  @DEFAULT_OPTIONS:
    width: null
    height: 30
    innerWidth: window.innerWidth - window.innerWidth * .2
    choiceText: ''
    color: ''

  constructor: () ->
    super
    @_width = @options.width-6
    @state = new StateModifier
      size: [@_width, @options.height]
    @mainNode = @add @state
    @createFlipper()
    @mainNode.add(@flipper)
    @state.setTransform Transform.translate(0,0,-3)

  createFlipper: () ->
    @createFront()
    @createBack()
    @flipper = new Flipper
      direction: Flipper.DIRECTION_Y
    
    @flipper.setFront(@front)
    @flipper.setBack(@back)


  # View used to display a question choice
  createFront: () ->
    @front = new ChoiceFrontView @options
    @front.pipe @._eventOutput

  # View used to display the answer status, i.e. right or wrong
  createBack: () ->
    @back = new ChoiceBackView @options
    @back.pipe @._eventOutput

  # @param status {string} either 'fail' or 'win'
  showStatusMsg: (status) =>
    @back.update(status)
    @flipper.flip(undefined, () =>

      if status is 'fail'
        Timer.setTimeout @remove, 1000

      if status is 'win'
        Timer.setTimeout(() =>
          @_eventOutput.emit('choice:doneShowingStatus');
        , 1000)
    )

  remove: () =>
    transition = 
      curve: 'linear'
      duration: 300

    @state.setOpacity(0.001, transition)
    @state.setSize([@_width, 0], transition, () =>
      @state.setTransform Transform.translate(0,0,-10)
    )


## Flipper Front View

class ChoiceFrontView extends View
  @DEFAULT_OPTIONS:
    width: null
    height: 30
    innerWidth: window.innerWidth - window.innerWidth * .2
    choiceText: ''
    color: ''

  constructor: () ->
    super
    @_width = @options.width-6
    @state = new StateModifier
      size: [@_width, @options.height]
      align: [0.5, 0.5]
      origin: [0.5, 0.5]

    @createBacking()

    @mainNode = @add @state
    @mainNode.add @backing

  createBacking: () ->
    @backing = new Surface
      classes: ["card__front__option", "option__front", "#{@options.color}"]
      content: "
                <div class='outerContainer' style='width: #{@options.innerWidth}px; height: #{@options.height}px;'>
                  <div class='innerContainer'>
                   #{@options.choiceText}
                  </div>
                </div>
               "
    @backing.pipe @._eventOutput


## Flipper Back View

class ChoiceBackView extends View
  @DEFAULT_OPTIONS:
    width: null
    height: 30
    innerWidth: window.innerWidth - window.innerWidth * .2
    choiceText: ''
    color: ''

  constructor: () ->
    super
    @_width = @options.width-6
    @state = new StateModifier
      size: [@_width, @options.height]
      align: [0.5, 0.5]
      origin: [0.5, 0.5]

    @createBacking()

    @mainNode = @add @state
    @mainNode.add @backing

  createBacking: () ->
    @backing = new Surface
      content: ""

    @backing.pipe @._eventOutput

  # @param status {string} either 'fail' or 'win'
  update: (status) ->
    msg = PlayStore.getMessage(status)
    @backing.setClasses(["card__front__option", "option__back", "#{@options.color}", "#{status}"])
    @backing.setContent("
      <div class='outerContainer' style='width: #{@options.innerWidth}px; height: #{@options.height}px;'>
        <div class='innerContainer'>
         #{msg}
        </div>
      </div>
    ")

module.exports = ChoiceView
