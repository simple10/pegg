require './scss/me.scss'

# Famo.us
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier = require 'famous/src/core/Modifier'

# Pegg
LayoutManager = require 'views/layouts/LayoutManager'
UnicornParts = require 'assets/UnicornParts'

class MeView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'MeView'

    @initSurfaces()

  initSurfaces: ->

    ## Front Card
    @mecorn = new Surface
      size: @layout.unicorn.size
    mecornMod = new Modifier
      origin: @layout.unicorn.origin
      align: @layout.unicorn.align
    @add(mecornMod).add @mecorn

    @mecorn.setContent "#{UnicornParts.start}
      #{UnicornParts.cosmic.tail}
      #{UnicornParts.cosmic.body}
      #{UnicornParts.cosmic.eyes}
      #{UnicornParts.cosmic.hair}
      #{UnicornParts.cosmic.horn}
      #{UnicornParts.end}"

module.exports = MeView
