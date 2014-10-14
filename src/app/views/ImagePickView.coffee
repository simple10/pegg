Config = require('Config').public
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'

# todo: add script to dom and init view when loaded or use bower
# <script type="text/javascript" src="//api.filepicker.io/v1/filepicker.js"></script>

class ImagePickView extends View

  constructor: (options) ->
    super options
    if filepicker?
      filepicker.setKey Config.filepicker.apiKey

  pick: (cb) ->
    if filepicker?
      filepicker.pickAndStore mimetype: "image/*", {path: '/orig/'}, (InkBlobs) ->
        result = InkBlobs[0]
        result.fullS3 = Config.s3.bucket + InkBlobs[0].key
        filepicker.convert InkBlobs[0], { width: 100, height: 100, fit: 'clip', format: 'jpg'} , { path: '/thumb/' }, (thumbBlob) =>
          thumbBlob.S3 = Config.s3.bucket + thumbBlob.key
          result.thumb = thumbBlob
          cb(result)



module.exports = ImagePickView

