###*
@jsx React.DOM
###

require 'styles/questions'

React = require 'react'
Layout = require 'layout/Layout'

CreateQuestionPage = React.createClass
  handleClick: ->
    alert('click')

  render: ->
    content = @transferPropsTo `
      <form className="questions--create">
        <h1>Create Question</h1>
      </form>
    `

    @transferPropsTo `
      <Layout active="home">
        {content}
      </Layout>
    `

module.exports = CreateQuestionPage
