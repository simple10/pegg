require './scss/card.scss'

View = require 'famous/core/View'
ScrollContainer = require 'famous/views/ScrollContainer'
ScrollView = require 'famous/views/Scrollview'
StateModifier = require 'famous/modifiers/StateModifier'
# SequentialLayout = require 'famous/views/SequentialLayout'
Surface = require 'famous/core/Surface'
ListItemView = require 'views/ListItemView'
PlayStore = require 'stores/PlayStore'
ChoiceView = require 'views/ChoiceView'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'
LayoutManager = require 'views/layouts/LayoutManager'

class ChoicesView extends View

  constructor: () ->
    super
    @choices = []
    @scrollView = new ScrollContainer
      container:
        size: @options.size
        classes: ['card__options__box']
    @scrollMod = new StateModifier
      align: @options.align
      origin: @options.origin
    @scrollView.sequenceFrom @choices
    @add(@scrollMod).add @scrollView

  load: (choices) ->
    @clearChoices()

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

  clearChoices: () ->
    @choices.length = 0

#  showChoices: () ->
#    for choiceView in @choices
#      choiceView.state.setTransform Transform.translate(0,0,5)
#
#  hideChoices: () ->
#    for choiceView in @choices
#      choiceView.state.setTransform Transform.translate(0,0,-3)

  fail: (choice, i) ->
    choiceView = @choices[i]
    choiceView.showStatusMsg('fail')

  win: (choice, i) ->
    choiceView = @choices[i]
    choiceView.showStatusMsg('win')



module.exports = ChoicesView
