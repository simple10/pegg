View = require 'famous/core/View'
Utility = require 'famous/utilities/Utility'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
SequentialLayout = require 'famous/views/SequentialLayout'
Surface = require 'famous/core/Surface'
InputSurface = require 'famous/surfaces/InputSurface'


class EditQuestionView extends View
  constructor: (model, options) ->
    super options
    @model = model
    @build()

  # Build view
  build: ->
    margin = 50
    width = window.innerWidth - 50*2

    @editForm = new SequentialLayout
      direction: Utility.Direction.Y

    @question = new InputSurface
      size: [width, 50]
      name: 'inputQuestion'
      placeholder: 'Type your question'
      value: ''
      type: 'text'

    @button = new Surface
      size: [width, 50]
      content: '<button>Next</button>'

    @button.on 'click', =>
      alert('button clicked!')

    @editForm.sequenceFrom [@question, @button]

    @add(new Modifier
      transform: Transform.translate margin, margin, 0
    ).add @editForm

module.exports = EditQuestionView
