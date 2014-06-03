Utils = require 'Utils'
helper = require 'spec/helpers/Common'
expect = helper.expect


describe 'Utils', ->

  describe '#keyMirror', ->
    it 'creates new enumeration with values equal to keys', ->
      obj =
        'a': null
        'b': 1
        'c': true
      newObj = Utils.keyMirror obj
      expect(newObj['a']).to.equal 'a'
      expect(newObj['b']).to.equal 'b'
      expect(newObj['c']).to.equal 'c'
