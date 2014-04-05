###*
@jsx React.DOM
###

React = require 'react'
ReactHack = require 'ReactHack'
Layout = require 'layout/Layout'
Secrets = require '../../config/secrets'

UploadPage = React.createClass
  handleSubmit: (e) ->
    e.preventDefault()
    image = e.target.value

    $.ajax
      url: Secrets.gatekeeper.s3policy + "/" + @state.filename.split("\\").pop()
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
        xhr.open "POST", Secrets.s3bucket
        xhr.onload = (res) ->

          console.log res
          if xhr.responseText
            console.log xhr.responseText
          else
            $.ajax
              url: Secrets.gatekeeper.blitlineSig
              success: (signature) ->
                #send json to blitline woth
                #public_token : “YOUR_PUBLIC_TOKEN!”
                #expires    : “Tue, 25 Dec 2012 00:00:00 -0800”
                #signature : “SIGNATURE_FROM_ABOVE”
                return

              error: (res, status, error) ->
                console.log error
                #do some error handling here
                #callback error
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
