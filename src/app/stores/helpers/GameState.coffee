EventHandler = require 'famous/core/EventHandler'
StageState = require 'stores/helpers/StageState'

class GameState extends EventHandler
  constructor: (data) ->
    super
    @_stages = for stageData in data
      stage = new StageState stageData
      stage.pipe @
      stage

  loadNextStage: (mood) ->
    # Start with the first stage
    if @_currentStageIdx? then @_currentStageIdx++ else @_currentStageIdx = 0
    @_currentStage = @_stages[@_currentStageIdx]

    # Start over from the first stage if all stages have been loaded
    if !@_currentStage?
      @_currentStageIdx = 0
      @_currentStage = @_stages[@_currentStageIdx]

    # if cards in Stage, load cards
    if @_currentStage._play.size > 0
      @_currentStage.loadCards mood
    # else load status
    else
      @loadStatus()
    @_currentStage

  loadStatus: ->
    @_currentStage.loadStatus()

  getCards: ->
    @_currentStage.getCardSet()

  getChoices: (cardId) ->
    @_currentStage.getChoices(cardId)

  getStatus: ->
    @_currentStage.getStatus()

module.exports = GameState
