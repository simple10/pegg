Config = require('Config').public
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'

# todo: add script to dom and init view when loaded or use bower
# <script type="text/javascript" src="//api.filepicker.io/v1/filepicker.js"></script>

class ImagePickView extends View

  constructor: (options) ->
    super options
    filepicker.setKey Config.filepicker.apiKey

  pick: (cb) ->
    filepicker.pickAndStore mimetype: "image/*", {}, (InkBlobs) =>
      cb InkBlobs


module.exports = ImagePickView

