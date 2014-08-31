var coffee = require('coffee-script');

module.exports = {
  process: function(src, path) {
    console.error('~');
    if (path.match(/\.coffee$/)) {
      return coffee.compile(src, {'bare': true});
    }
    return src;
  }
};
