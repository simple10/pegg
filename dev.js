var webpackMiddleware = require("webpack-dev-middleware");
var webpack = require("webpack");
var express = require("express");
var app = express();

app.use(webpackMiddleware(webpack({
    // webpack options
    // webpackMiddleware takes a Compiler object as first parameter
    // which is returned by webpack(...) without callback.
//    entry: ["webpack-dev-server/client?http://localhost:8080", "./src"],
    output: {
        path: "/"
        // no real path is required, just pass "/"
        // but it will work with other paths too.
    }
}), {
    // all options optional

    noInfo: false,
    // display no info to console (only warnings and errors)

    quiet: false,
    // display nothing to the console

    lazy: false,
    // switch into lazy mode
    // that means no watching, but recompilation on every request

    watchDelay: 300,
    // delay after change (only lazy: false)
//
    publicPath: "dist/",
//    // public path to bind the middleware to
//    // use the same as in webpack

    headers: { "X-Custom-Header": "yes" },
    // custom headers

    stats: {
        colors: true
    }
    // options for formatting the statistics
}));

var port = Number(process.env.PORT || 8080);

app.listen(port, function() {
    console.log("Listening on " + port);
});

