chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

module.exports =
  expect: chai.expect
  spy: sinon.spy
  stub: sinon.stub
  sinon: sinon
