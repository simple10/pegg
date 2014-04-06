###*
@jsx React.DOM
###

React = require 'react'
ReactHack = require 'ReactHack'
Layout = require 'layout/Layout'
Config = require('config').public

UploadPage = React.createClass
  handleSubmit: (e) ->
    e.preventDefault()
    image = e.target.value

    $.ajax
      url: Config.gatekeeper.server + "/s3policy/" + @state.filename.split("\\").pop()
      success: (creds) ->

        loc = "img/" + creds.filename
        fd = new FormData()
        fd.append "key", loc
        fd.append "AWSAccessKeyId", creds.s3Key
        fd.append "acl", "public-read"
        fd.append "policy", creds.s3PolicyBase64
        fd.append "signature", creds.s3Signature
        fd.append "Content-Type", creds.s3Mime
        fd.append "file", image

        xhr = new XMLHttpRequest()
        xhr.open "POST", Config.upload.s3bucket
        xhr.onload = (res) ->

          console.log res
          if xhr.responseText
            console.log xhr.responseText
          else
            job =
              url: res
              filename: creds.filename

            $.post(Config.upload.server, job, (data) ->
                console.log data
                return
            , "json").fail (error) ->
                console.log error
                return
          return

        xhr.send fd
        return

      error: (res, status, error) ->
        console.log error
        #do some error handling here
        #callback error
        return

  handleChange: (e) ->
    @setState filename: e.target.value

  render: ->
    form = @transferPropsTo `
      <form onSubmit={this.handleSubmit}>
          <fieldset>
            <input type="file" name="image" onChange={this.handleChange}/>
            <input type="submit" value="Upload" />
          </fieldset>
        </form>
      `

    @transferPropsTo `
      <Layout active="home">
        {form}
      </Layout>
    `

module.exports = UploadPage
