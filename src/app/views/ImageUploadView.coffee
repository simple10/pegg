Config = require('config').public.aviary
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'

# todo: add script to dom and init view when loaded
# <script type="text/javascript" src="http://feather.aviary.com/js/feather.js"></script>

class ImageEditView extends View
  src: 'http://images.aviary.com/imagesv5/feather_default.jpg'
  theme: 'dark' # light

  constructor: (options) ->
    super options
    @initEditor()
    @build()

  # Build view
  build: ->
    @surface = new Surface
      content: "
              <div id='injection_site' style='width:400; height: 800'></div>
              <img id='image1' src='#{@src}'>
            "
      size: [undefined, undefined]
    @surface.on 'click', =>
      @launchEditor 'image1', @src

    @add @surface

  launchEditor: (id, src) ->
    @aviary.launch
      image: id
      url: src

  initEditor: ->
    @aviary = new Aviary.Feather
      apiKey: Config.apiKey
      apiVersion: 3
      theme: 'minimum'
      tools: 'all'
      appendTo: ''
      onSave: @onSave
      onError: @onError

  onSave: (imageID, newURL) =>
    debugger
    img = document.getElementById(imageID)
    img.src = newURL

  onError: (errorObj) =>
    debugger

module.exports = ImageEditView

