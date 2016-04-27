files = require(".")()

index =
  head: """
    <!DOCTYPE HTML><meta charset="UTF-8">
    <title>Facts • playful outformation model for ECMAScript</title>
    <script src="Facts.pack.js"></script>
    <link rel="icon" type="image/png" href="Documentation/images/icon.png">
  """
  style: """
    Documentation/core.css
    Documentation/index.css
  """
  body: """
    Documentation/index.header.html
    Documentation/index.foreword.html
    Documentation/index.downloads.html
    Documentation/index.tutorial.html
    Documentation/index.constructor.html
    Documentation/index.methods.html
    Documentation/index.properties.html
    Documentation/index.functions.html
    Documentation/index.installation.html
    Documentation/index.examples.html
    Documentation/index.appendix.html
    Documentation/index.nav.html
    Documentation/index.footer.html
  """
  script: """
    Documentation/scripts/highlight.pack.js
    Documentation/window.coffee
    Documentation/syntax.highlight.coffee
    Documentation/width.height.coffee
    Documentation/index.coffee
    Documentation/index.scroll.coffee
    Documentation/index.videos.coffee
  """

indexHTML = (callback) ->
  head = index.head
  stylesheets = index.style.split("\n")
  body = index.body.split("\n")
  scripts = index.script.split("\n")
  scripts.compiled = scripts.filter (identifier) -> /js/.test identifier
  scripts.uncompiled = scripts.filter (identifier) -> /coffee/.test identifier
  identifiers = [].concat(stylesheets).concat(body).concat(scripts)
  tasks = identifiers.map (identifier) -> (done) -> initialize identifier, done
  parallel tasks, (error) ->
    if error then callback error else callback undefined, new Buffer """
      #{index.head}
      <style media="screen">
      #{(echo stylesheet for stylesheet in stylesheets).join("")}
      </style>
      <body>
      #{(echo element for element in body).join("")}
      </body>
      <script>
      #{(echo script for script in scripts.compiled).join("")}
      #{(compile echo script for script in scripts.uncompiled).join("")}
      </script>
    """

service = require("http").createServer (request, response) ->
  console.info request:identifier=decodeURIComponent(request.url.replace("/",""))
  switch
    when identifier is "index.html"
      indexHTML (error, HTML) ->
        if error then throw error
        send response, output =
          file:"index.html"
          type:"text/html; charset=UTF-8"
          size:HTML.length
          data:HTML
        write identifier, HTML, "UTF8"
    when /js/.test identifier
      sendScript(identifier, response)
    when /png|jpg|svg|woff/.test identifier
      sendBinary(identifier, response)
    else
      console.error unhandled:identifier
      response.writeHead 404, "Content-Length":0
      response.end()

service.listen 8080, (error) ->
  if error then throw error
  console.info listening:service.address()
  console.info opening:"http://localhost:8080/index.html"
  exec "open http://localhost:8080/index.html", (error, stdout, stderr) ->
    if error then console.error(stderr) and throw error else console.info(stdout)

sendScript = (identifier, response) ->
  if script = files.pull(identifier)
    send response, out =
      file:identifier
      type:"application/ecmascript; charset=UTF-8"
      size:script.size
      data:script.data
  else
    memorize identifier, -> sendScript(identifier, response)

sendBinary = (identifier, response) ->
  read identifier, (error, data) ->
    if error then throw error else send response, output =
      file:identifier
      type:mime.lookup(identifier)
      size:data.length
      data:data

send = (response, output) ->
  response.writeHead 200, "Content-Length":output.size, "Content-Type":output.type
  response.end output.data
  delete output.data
  console.info {output}

initialize = (identifier, done) ->
  if files.pull(identifier) is undefined
    watch identifier, (event) -> if event is "change" then memorize identifier
    console.info watching:identifier
    memorize identifier, done
  else
    done()

memorize = (identifier, done) ->
  read identifier, (error, data) ->
    files.add identifier,
      size:data.length
      data:data.toString("UTF-8")
    console.info memorized:identifier
    if done then done()

compile = require("coffee-script").compile

echo = (identifier) -> files.pull(identifier).data

exec = require("child_process").exec

mime = require("mime")

parallel = require("async").parallel

read = require("fs").readFile

watch = require("fs").watch

write = require("fs").writeFile
