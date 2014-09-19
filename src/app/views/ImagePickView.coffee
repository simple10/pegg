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
    filepicker.pickAndStore mimetype: "image/*", {path: '/uploaded/'}, (InkBlobs) ->
      result = InkBlobs[0]
      result.fullS3 = Config.s3.bucket + InkBlobs[0].key
      filepicker.convert InkBlobs[0], { width: 100, height: 100, fit: 'clip', format: 'jpg'} , { path: '/processed/' }, (thumbBlob) =>
        thumbBlob.s3 = Config.s3.bucket + thumbBlob.key
        result.thumb = thumbBlob
        cb(result)



module.exports = ImagePickView

