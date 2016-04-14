document.on "DOMContentLoaded", (event) ->
  Array.from(document.querySelectorAll("pre.ecmascript,code")).forEach (element) ->
    element.classList.add("js")
    hljs.highlightBlock(element)
