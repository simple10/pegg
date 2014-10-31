require './scss/card.scss'
_ = require('Parse')._

View = require 'famous/src/core/View'
ScrollContainer = require 'famous/src/views/ScrollContainer'
ScrollView = require 'famous/src/views/Scrollview'
StateModifier = require 'famous/src/modifiers/StateModifier'
# SequentialLayout = require 'famous/src/views/SequentialLayout'
Surface = require 'famous/src/core/Surface'
ListItemView = require 'views/ListItemView'
PlayStore = require 'stores/PlayStore'
ChoiceView = require 'views/ChoiceView'
Transform = require 'famous/src/core/Transform'
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

  load: (choices, answer) ->
    @clearChoices()

    for own id, choice of choices
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
        winOrFail = null
        if answer?
          if answer.id is id
            winOrFail = 'win'
          else
            winOrFail = 'fail'
        choiceView.on 'click', ((id, winOrFail, choiceView) ->
          @_eventOutput.emit 'choice', id
          if winOrFail?
            choiceView.showStatusMsg winOrFail
          else
            choiceView.highlight()
        ).bind @, id, winOrFail, choiceView
        choiceView.on 'choice:doneShowingStatus', ((id) ->
          @_eventOutput.emit 'choice:doneShowingStatus'
        ).bind @, id
        @choices.push choiceView
        choiceView.pipe @scrollView

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


module.exports = ChoicesView
