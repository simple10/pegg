###*
@jsx React.DOM
###

require 'styles/home'

React = require 'react'
Layout = require 'layout/Layout'

HomePage = React.createClass
  handleClick: ->
    alert('click')

  render: ->
    links = ['upload', 'Test2', 'Test3'].map (name) =>
      @transferPropsTo `
        <li key={name}><a href={'#/pages/' + name}>{name}</a></li>
      `
    content = @transferPropsTo `
      <ul>
        {links}
      </ul>
    `

    @transferPropsTo `
      <Layout active="home">
        {content}
      </Layout>
    `

module.exports = HomePage
