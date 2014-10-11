<!DOCTYPE html>
<html>
  <head>
    <title>{%=o.htmlWebpackPlugin.options.title || 'Pegg'%}</title>
    <meta name="viewport" content="width=device-width, maximum-scale=1, user-scalable=no" />
    <meta name="mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
  </head>
  <body>
    <div id="fb-root"></div>
  </body>
  <script type="text/javascript" src="//api.filepicker.io/v1/filepicker.js"></script>
{% for (var chunk in o.htmlWebpackPlugin.assets) { %}
  <script src="{%=o.htmlWebpackPlugin.assets[chunk]%}"></script>
{% } %}
</html>
