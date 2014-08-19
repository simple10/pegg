require './scss/card.scss'

View = require 'famous/core/View'
Timer = require 'famous/utilities/Timer'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Flipper = require 'famous/views/Flipper'
PlayStore = require 'stores/PlayStore'
Utils = require 'lib/Utils'

class ChoiceView extends View
  @DEFAULT_OPTIONS:
    size: null
    innerWidth: 0
    choiceText: ''
    color: ''

  constructor: () ->
    super
    @state = new StateModifier
      size: @options.size
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
        Timer.setTimeout @remove, 500

      if status is 'win'
        Timer.setTimeout(() =>
          @_eventOutput.emit('choice:doneShowingStatus');
        , 500)
    )

  remove: () =>
    transition = 
      curve: 'linear'
      duration: 300

    @state.setOpacity(0.001, transition)
    @state.setSize([@options.size[0], 0], transition, () =>
      @state.setTransform Transform.translate(0,0,-10)
    )


## Flipper Front View

class ChoiceFrontView extends View
  constructor: () ->
    super
    @state = new StateModifier
      size: @options.size
      align: @options.align
      origin: @options.origin

    @createBacking()

    @mainNode = @add @state
    @mainNode.add @backing

  createBacking: () ->

    @backing = new Surface
      classes: ["card__front__option", "option__front"] #, "#{@options.color}"
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

  constructor: () ->
    super
    @state = new StateModifier
      size: @options.size
      align: @options.align
      origin: @options.origin

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
#    , "#{@options.color}"
    @backing.setClasses(["card__front__option", "option__back", "#{status}"])
    @backing.setContent("
      <div class='outerContainer' style='width: #{@options.innerWidth}px; height: #{@options.height}px;'>
        <div class='innerContainer'>
         #{msg}
        </div>
      </div>
    ")

module.exports = ChoiceView
