View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utils = require 'lib/Utils'

class ConfirmCancelView extends View
  @DEFAULT_OPTIONS:
    showTransform: Transform.translate(0,70,20)
    showTransition: true
    hideTransform: Transform.translate(0,150,20)
    hideTransition: true
    doneCallback: (->)
    cancelCallback: (->)
    size: [undefined, 50]
    btnSize: [Utils.getViewportWidth(), 30]
    classes: []

  constructor: ->
    super

    @init()

  init: ->
    # add root modifier
    @mainMod = new StateModifier
      size: @options.size
      origin: [0.5, 1]
      align: [0.5, 1]
      transform: @options.showTransform

    # init surfaces
    @initSurfaces()
    @initListeners()

    # hide
    @hide()

  initSurfaces: ->
     # init backing
    @backing = new Surface
      classes: @options.classes.concat(['confirmOrCancel'])

    # init buttons
    # @cancelBtn = new Surface
    #   classes: @options.classes.concat(['confirmOrCancel__btn', 'btn', 'cancel-btn'])
    #   content: 'Cancel'
    #   properties:
    #     textAlign: 'center'
    #     lineHeight: @options.btnSize[1] + 'px'
    @doneBtn = new Surface
      classes: @options.classes.concat(['confirmOrCancel__btn', 'btn', 'done-btn'])
      content: 'Done'
      properties:
        textAlign: 'center'
        lineHeight: @options.btnSize[1] + 'px'
    # @cancelBtnMod = new StateModifier
    #   size: @options.btnSize
    #   origin: [0.5, 0.5]
    #   align: [0.5, 0.5]
    #   transform: Transform.translate(-55, 0, 1)
    @doneBtnMod = new StateModifier
      size: @options.btnSize
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
      # transform: Transform.translate(55, 0, 1)

    # add everything to the render node
    node = @add @mainMod
    node.add @backing
    # node.add(@cancelBtnMod).add @cancelBtn
    node.add(@doneBtnMod).add @doneBtn

  initListeners: ->
    @doneBtn.on 'click', () =>
      @_eventOutput.emit 'click:done'
      @hide()

    # @cancelBtn.on 'click', () =>
    #   @_eventOutput.emit 'click:cancel'
    #   @hide()

  show: (cb) ->
    cb = cb || (->)
    @mainMod.setTransform(@options.showTransform, @options.showTransition, cb)

  hide: (cb) ->
    cb = cb || (->)
    @mainMod.setTransform(@options.hideTransform, @options.hideTransition, cb)

module.exports = ConfirmCancelView
