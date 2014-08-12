# NewCardView1
#
# Enter question and continue

require './scss/newcard.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
InputSurface = require 'famous/surfaces/InputSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'
NewCardStore = require 'stores/NewCardStore'
UserStore = require 'stores/UserStore'
CardActions = require 'actions/CardActions'
Utils = require 'lib/Utils'
Scrollview = require 'famous/views/Scrollview'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Constants = require 'constants/PeggConstants'

# Custom View
InputView = require 'views/InputView'
ConfirmCancelView = require 'views/ConfirmCancelView'

# Layouts
HeaderViewLayout = require 'views/layouts/mobile/HeaderViewLayout'

class NewCardView extends View

  constructor: ->
    super
    
    @_numOfselectedCategories = 0
    @_selectedCategories = {}
    
    @initSurfaces()
    @initListeners()


  initListeners: ->
    NewCardStore.on Constants.stores.CATEGORIES_CHANGE, @loadCategories

    @on 'click:category', (data) =>
      category = @_selectedCategories[data.id]
     
      # update the selected categories
      if category?
        # deselect the category
        data.surface.removeClass('selected')
        delete @_selectedCategories[data.id]
        @_numOfselectedCategories--
      else
        # select the cateogory
        data.surface.addClass('selected')
        @_selectedCategories[data.id] = data.surface
        @_numOfselectedCategories++

      if @_numOfselectedCategories
        @categoriesConfirm.show()
      else
        @categoriesConfirm.hide()

    @categoriesConfirm.on 'click:done', () =>
      # console.log 'done'
      @hideCategories()

    @categoriesConfirm.on 'click:cancel', () =>
      # console.log 'cancel'
      @_resetSelectedCategories()
      @hideCategories()

  loadCategories: =>
    categories = NewCardStore.getCategories()
    for category, key in categories
      categorySurface = new Surface
        size: @options.category.size
        classes: @options.category.classes
        content: "<span class='category-name'>#{category.get 'name'}</span>"
      @categorySurfaces.push categorySurface
      categorySurface.on('click', ((surface, category) ->
        @_eventOutput.emit 'click:category', {
          surface: surface
          id: category.id
        }).bind(@, categorySurface, category)
      )
      categorySurface.pipe @categoryScrollview

  initSurfaces: ->
    @step1Mods = []
    @step1Inputs = []
    @step2Mods = []
    @step2Inputs = []
    @step4Mods = []
    @step3Mods = []

    headerHeight = HeaderViewLayout.size[1]
#    @back = new ImageSurface
#      size: [50, 50]
#      content: '/images/back.png'
#      classes: ['play__back']
#    @back.on 'click', =>
#      @cards.goToPreviousPage()
#    @backMod = new StateModifier
#      align: [0, 0]
#      origin: [0, 1]
#    @playNode.add(@backMod).add @back
    cardIcon = new ImageSurface
      size: @options.cardIcon.size
      classes: @options.cardIcon.classes
      content: 'images/newcard_medium2.png'
    cardIconMod = new StateModifier
      origin: @options.cardIcon.origin
      align: @options.cardIcon.align
    @add(cardIconMod).add cardIcon
    @newCardTitle = new Surface
      size: @options.newCardTitle.size
      content: 'NEW CARD'
      classes: @options.newCardTitle.classes
    newCardMod = new StateModifier
      origin: @options.newCardTitle.origin
      align: @options.newCardTitle.align
    @add(newCardMod).add @newCardTitle


    @container = new ContainerSurface
      size: [Utils.getViewportWidth(), Utils.getViewportHeight() - headerHeight]
      classes: ['categoriesContainer']
      properties:
        overflow: 'hidden'
    @categoryScrollviewMod = new StateModifier
      origin: @options.categories.origin
      align: @options.categories.align
      transform: Transform.translate 0, headerHeight, 1
    @categoryScrollview = new Scrollview
      # size: @options.categories.size
      # classes: @options.categories.classes
    @categorySurfaces = []
    @categoryScrollview.sequenceFrom @categorySurfaces

    @container.add @categoryScrollview
    @add(@categoryScrollviewMod).add @container
    
    @categoriesConfirm = new ConfirmCancelView
      classes: ['newcard']

    @add @categoriesConfirm


    ## STEP 1
    @addNum(1, 0)
    @addInputView(1, 1, 'Enter a question')
    @addButton(1, 2, 'Continue', =>
      question =  @step1Inputs[0].getValue()
      if question.length > 5
        CardActions.addQuestion question
        @hideStep 'step1', @step1Mods
        @step2()
      else
        alert 'Please enter a question.'
    )
    ## STEP 2
    @addNum(2, 0)
    for i in [1..4]
      @addInputView(2, i, "Answer option #{i}")
    @addButton(2, 5, 'Continue', =>
      answers = []
      for input in @step2Inputs
        answer = input.getValue()
        if answer.length > 0 then answers.push answer
      if answers.length >= 2
        CardActions.addAnswers answers
        @hideStep 'step2', @step2Mods
        @step3()
      else
        alert 'Please enter at least 2 answer options.'
    )
    ## STEP 3
    @addNum(3, 0)
    @addLinkContainer(3, 1,
      'images/deck_existing.png'
      'Place card in existing deck(s)'
    , () => 
      @showCategories()
    )
    @addLinkContainer(3, 2,
      'images/deck_new2.png'
      'Create a new deck'
    , =>
      alert "new deck"
    )
    @addButton(3, 3, 'Finish', =>
      @hideStep 'step3', @step3Mods
      CardActions.addCategories Object.keys @_selectedCategories
      @step4()
    )
    ## STEP 4
    @addSurface(4, 0, 'CREATED!')
    @addButton(4, 1,'Play this card', =>
      @hideStep 'step4', @step4Mods
      @step1()
      #TODO: play card
    )
    @addButton(4, 2, 'Create another card', =>
      @hideStep 'step4', @step4Mods
      #TODO: reset all fields to empty
      @step1()
    )
    @step1()

  step1: ->
    @showStep 'step1', @step1Mods

  step2: ->
    Timer.after (=>
      @showStep 'step2', @step2Mods
    ), 30

  step3: ->
    Timer.after (=>
      @showStep 'step3', @step3Mods
    ), 30

  step4: ->
    Timer.after (=>
      @showStep 'step4', @step4Mods
    ), 30

  showStep: (step, mods) ->
    i = 0
    for mod in mods
      Utils.animate mod, @["options"]["#{step}_#{i}"].states[0]
      i++

  hideStep: (step, mods) ->
    i = 0
    for mod in mods
      Utils.animate mod, @["options"]["#{step}_#{i}"].states[1]
      i++

  showCategories: () ->
    Utils.animate @categoryScrollviewMod, @options.categories.states[0]
    if @_numOfselectedCategories
      @categoriesConfirm.show()

  hideCategories: () ->
    Utils.animate @categoryScrollviewMod, @options.categories.states[1]

  _resetSelectedCategories: () ->
    for id, surface of @_selectedCategories
      surface.removeClass('selected')

    @_numOfselectedCategories = 0
    @_selectedCategories = {}
    

  addInputView: (step, num, placeholder)->
    inputView = new InputView
      size: @options["step#{step}_#{num}"].size
      placeholder: placeholder
      align: @options["step#{step}_#{num}"].states[0].align
      origin: @options["step#{step}_#{num}"].origin
      transform: @options["step#{step}_#{num}"].states[0].transform
    inputViewMod = new StateModifier
      origin: @options["step#{step}_#{num}"].origin
      align: @options["step#{step}_#{num}"].align
    @["step#{step}Mods"].push inputViewMod
    @["step#{step}Inputs"].push inputView
    @add(inputViewMod).add inputView

  addSurface: (step, num, content)->
    surface = new Surface
      size: @options["step#{step}_#{num}"].size
      content: content
      classes: @options["step#{step}_#{num}"].classes
    surfaceMod = new StateModifier
      align: @options["step#{step}_#{num}"].align
      origin: @options["step#{step}_#{num}"].origin
    @["step#{step}Mods"].push surfaceMod
    @add(surfaceMod).add surface

  addNum: (step, num)->
    numSurface = new Surface
      size: @options["step#{step}_#{num}"].size
      content: step
      classes: @options["step#{step}_#{num}"].classes
    numMod = new StateModifier
      origin: @options["step#{step}_#{num}"].origin
      align: @options["step#{step}_#{num}"].align
    @["step#{step}Mods"].push numMod
    @add(numMod).add numSurface

  addButton: (step, num, text, func)->
    submit = new Surface
      size: @options["step#{step}_#{num}"].size
      content: text
      classes: @options["step#{step}_#{num}"].classes
      properties:
        lineHeight: @options["step#{step}_#{num}"].size[1] + 'px'
    submitMod = new StateModifier
      origin: @options["step#{step}_#{num}"].origin
      align: @options["step#{step}_#{num}"].align
    @["step#{step}Mods"].push submitMod
    @add(submitMod).add submit
    submit.on 'click', func

  addLinkContainer: (step, num, image, text, func) ->
    imageSurface = new ImageSurface
      size: @options["step#{step}_#{num}"].size[1]
      classes: @options["step#{step}_#{num}"].classes.image
      content: image
    imageMod = new StateModifier
      origin: [0, 0.5]
      align: [0, 0.5]
    textSurface = new Surface
      size: @options["step#{step}_#{num}"].size[2]
      content: text
      classes: @options["step#{step}_#{num}"].classes.text
      properties:
        lineHeight: "#{@options["step#{step}_#{num}"].size[0]}px"
    textMod = new StateModifier
      origin: [0, 0.5]
      align: [0.25, 0.5]
    container = new ContainerSurface
      size: @options["step#{step}_#{num}"].size[0]
    container.add(imageMod).add imageSurface
    container.add(textMod).add textSurface
    containerMod = new StateModifier
      origin: @options["step#{step}_#{num}"].origin
      align: @options["step#{step}_#{num}"].align
    @["step#{step}Mods"].push containerMod
    @add(containerMod).add container
    container.on 'click', func


module.exports = NewCardView
