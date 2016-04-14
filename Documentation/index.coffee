window.addEventListener "load", ->
  window.requestAnimationFrame ->
    document.querySelector("body").classList.add("initialized")

document.on "mouseover", "div.console:not(.invoked)", (event, div) ->
  transactionID = "T#{Date.now()}"
  for stringElement in div.querySelectorAll("pre.output .hljs-string")
    if stringElement.innerText is '"TNOW"'
      stringElement.innerText = '"'+transactionID+'"'
  Function.delay 33, ->
    window.requestAnimationFrame ->
      div.classList.add("invoked")
      window.requestAnimationFrame ->
        div.classList.add("returned")
