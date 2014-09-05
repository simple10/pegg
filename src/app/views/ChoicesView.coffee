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
Utils = require 'lib/Utils'

class ChoicesView extends View

  constructor: () ->
    super
    @choices = []
    container = new ContainerSurface
      size: @options.size
#      properties:
#        overflow: 'hidden'
      classes: ['card__options__box']
    @scrollView = new Scrollview
      size: @options.size
    @scrollView.sequenceFrom @choices
    container.add @scrollView
    @add container
#    container.pipe @scrollView

  load: (choices) ->
    @choices.length = 0

    i=0
    for choice in choices
      choiceText = choice.text
      if choiceText
#        if choiceText.length > 30
#          height = 50 + Math.floor(choiceText.length/30) * 8
#        else
#        height = @options.size[1] / 4
#        if i % 2
#          color = 'light'
#        else
#          color = 'dark'
        @options.choice.choiceText = choiceText
        choiceView = new ChoiceView @options.choice
        choiceView.on 'click', ((i) ->
          @_eventOutput.emit 'choice', i
        ).bind @, i
        choiceView.on 'choice:doneShowingStatus', ((i) ->
          @_eventOutput.emit 'choice:doneShowingStatus', i
        ).bind @, i
        @choices.push choiceView
        choiceView.pipe @scrollView
        i++

    #newChoice = new Surface
    #  size: [ @options.width - 50, @options.height ]
    #  content: "<input type='text' name='newOption' placeholder='Type your own...'>"
    #  classes: ['card__front__input']
    #surfaces.push newChoice



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
