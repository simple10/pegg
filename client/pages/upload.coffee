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
    $.ajax
      url: Secrets.s3.credServer + "/creds/" + @state.filename.split("\\").pop()
      success: (creds) ->
        console.log Secrets.s3.credServer + "/creds/  -  Returned successfully. "

        loc = "img/" + creds.filename
        fd = new FormData()
        fd.append "key", loc
        fd.append "AWSAccessKeyId", creds.s3Key
        fd.append "acl", "public-read"
        fd.append "policy", creds.s3PolicyBase64
        fd.append "signature", creds.s3Signature
        fd.append "Content-Type", creds.s3Mime
        #fd.append "file", image

        xhr = new XMLHttpRequest()
        xhr.open "POST", Secrets.s3.bucket
        xhr.onload = (res) ->
          console.log xhr.responseText
          console.log res
          if xhr.responseText
            callback xhr.responseText
          else
            callback "Success"
          return

        xhr.send fd

        console.log fd

        #callback res
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
