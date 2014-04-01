Frontend StarterKit is a barebones framework with [gulp](http://gulpjs.com/) and [webpack](http://webpack.github.io/) fully configured for rapid development.

Webpack runs webpack-dev-server in development for on-the-fly compilation of source file changes. It can also compile assets for production.

CoffeeScript, SCSS, Zurb Foundation, and Bower are installed and configured.

By default, CSS files are included by requiring them in JavaScript files via webpack magic. This reduces network latency and allows webpack to intelligently manage which files are actually required. See [src/js/head.coffee](https://github.com/starterkits/frontend-starterkit-minimal/blob/master/src/js/head.coffee).


# Install

```bash
git clone https://github.com/starterkits/frontend-starterkit-minimal.git
cd frontend-starterkit-minimal
npm install -g webpack-dev-server bower
npm install
```

# Development

```bash
# Run webpack-dev-server
gulp

# Or manually run webpack if needed
webpack -d --colors
```

# Production

```bash
# Compile assets for production
gulp build
```


# Development Overview

Gulp is used instead of grunt to manage development tasks.
Gulp is easier to configure and faster due to streaming IO instead of writing files to disk.

Webpack is used instead of browserify to compile assets and manage JavaScript dependencies.
Webpack can handle CSS and other file types besides JavaScript. This allows for views to be
completely self contained with CSS, fonts, and JavaScript dependencies declared at the top
of the view file.

Gulp could be dropped since it's mostly just passing through to webpack. But gulp has a lot
of useful plugins and example tasks that could be useful later on.


# Debugging with React Developer Tools

Install [Chrome Extention](https://github.com/facebook/react-devtools).

React dev tools adds a React tab to Chrome's Developer Tools window. The tab will only
appear when inspecting a page directly. It will not appear when using webpack's dev server.

* Works: http://localhost:8080/index.html
* Doesn't work: http://localhost:8080/webpack-dev-server/index.html


# Directory Structure

* **/bin**: startup and task scripts
* **/client**: all code and assets for display and interaction; javascript, html, images, css, etc.
* **/config**: config vars and initializers
* **/lib**: shared code that doesn't obviously belong in client or server
* **/server**: all server-side and api code


# Dependencies

With webpack, each JavaScript file must explicitly require its dependencies.

By convention, each view should have a cooresponding CSS file in of the same name in /styles.
The CSS files should be explicitly required by the view vs assuming the CSS is already loaded.

Any changes to explicity required files will be automatically picked up by webpack and updated
in development. Files @imported in sass will not be automatically recompiled with the current
webpack configuration. Any changes to app.scss or _settings.scss requires a restart of the
development server.


# Templates

With React, templates are embedded in the view JavaScript file as either JSX syntax or React dom function calls.
This is a bit unnatural for MVC developers, but it ends up making life much easier as the project size grows.


# NPM vs Bower

Use Bower for any dependencies that are only used in the browser. Use npm for everything else.

React is installed via npm so it can render in node to speed up the first page render or for SEO.


# Production

The package.json and bower.json files should be updated to use specific versions to ensure
consistency between development and production.

Does npm have the equivalent of Bundler's Gemfile.lock?

## Deploy

```bash
# build production assets
gulp build
```

Rest of deploy details TBD.


# Sources

This project uses concepts from [ReactHack](https://github.com/petehunt/ReactHack) but explicity includes
files from [reacthack-core](petehunt/reacthack-core) to make code tracing and learning easier.

## Of Interest:

* https://github.com/facebook/react-devtools
* https://github.com/johnthethird/react-starter-template
* https://github.com/ericclemmons/genesis-skeleton
* https://github.com/neebz/backbone-parse
* https://usepropeller.com/blog/posts/from-backbone-to-react/





