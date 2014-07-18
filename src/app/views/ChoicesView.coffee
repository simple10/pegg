require './scss/card.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
StateModifier = require 'famous/modifiers/StateModifier'
# SequentialLayout = require 'famous/views/SequentialLayout'
Surface = require 'famous/core/Surface'
ListItemView = require 'views/ListItemView'
PlayStore = require 'stores/PlayStore'
ChoiceView = require 'views/ChoiceView'
Transform = require 'famous/core/Transform'

class ChoicesView extends View
  @DEFAULT_OPTIONS:
    width: null
    height: 30
    padding: 40
    innerWidth: window.innerWidth - window.innerWidth * .2

  constructor: () ->
    super

  load: (cardId) ->
    choices = PlayStore.getChoices(cardId)
    @choices = []
    @scrollView = new Scrollview
      size: [ @options.width, @options.height ]
    @scrollView.sequenceFrom @choices
    i=0
    for choice in choices
      choiceText = choice.text
      if choiceText
        if choiceText.length > 30
          height = 50 + Math.floor(choiceText.length/30) * 8
        else
          height = @options.height
        if i % 2
          color = 'light'
        else
          color = 'dark'
        # choiceSurface = new Surface
        #   size: [ @options.width-6, height ]
        #   classes: ["card__front__option", "#{color}"]
        #   content: "
        #             <div class='outerContainer' style='width: #{@options.innerWidth}px; height: #{height}px;'>
        #               <div class='innerContainer'>
        #                #{choiceText}
        #               </div>
        #             </div>"
        choiceSurface = new ChoiceView
          width: @options.width
          height: height
          innerWidth: @options.innerWidth
          choiceText: choiceText
          color: color
        choiceSurface.on 'click', ((i) ->
          @_eventOutput.emit 'choice', i
        ).bind @, i
        # choiceSurface.on 'scroll', =>
        #   @_eventOutput.emit 'scroll'
        @choices.push choiceSurface
        choiceSurface.pipe @scrollView
        i++

    #newChoice = new Surface
    #  size: [ @options.width - 50, @options.height ]
    #  content: "<input type='text' name='newOption' placeholder='Type your own...'>"
    #  classes: ['card__front__input']
    #surfaces.push newChoice

    container = new ContainerSurface
      size: [@options.width, 220]
      properties:
        overflow: 'hidden'
      classes: ['card__options__box']

    container.add @scrollView
    @add container

  showChoices: () ->
    for choiceView in @choices
      choiceView.state.setTransform Transform.translate(0,0,0)

  hideChoices: () ->
    for choiceView in @choices
      choiceView.state.setTransform Transform.translate(0,0,-3)

  fail: (choice, i) ->
    choiceView = @choices[i]
    choiceView.showStatusMsg('fail')

  win: (choice, i) ->
    choiceView = @choices[i]
    choiceView.showStatusMsg('win')



module.exports = ChoicesView
