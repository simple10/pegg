# NewCardView1
#
# Enter question and continue

require 'css/newcard'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'


class NewCardView extends View
  cssPrefix: 'newcard'

  @DEFAULT_OPTIONS


  constructor: ->
    super
    @init()

  init: ->
    questionInput = new Surface
      size: [true, true]
      content: '
          <input type="text" name="question" onChange=/>
        '
      classes: ["#{@cssPrefix}__question--input"]
    questionInput.on 'change', =>
      alert('question added')

    questionState = new StateModifier
      origin: [0, 0.5]
      transform: Transform.translate 0, 0, 0
    @add(questionState).add questionInput

    questionSubmit = new Surface
      size: [true, true]
      content: '
          <input type="submit" value="Upload" />
        '
      classes: ['newcard__question_submit']
    questionSubmit.on 'click', =>
      alert('question submitted')
    questionState = new StateModifier
      origin: [0, 0.5]
      transform: Transform.translate 0, 0, 0
    @add(questionState).add questionSubmit


module.exports = NewCardView