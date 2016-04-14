window.addEventListener "load", ->
  window.requestAnimationFrame ->
    if location.hash
      render id:location.hash.replace("#", "")

document.on "click", "a[href^='#']", (event, hyperlink) ->
  render id:hyperlink.href.toString().split("#")[1]

document.on "mousemove", "body > div[id]", (event, div) ->
  id = div.id
  baseURL = location.toString().split("#")[0]
  history.replaceState({}, "", "#{baseURL}##{id}") unless location.hash is "##{id}"
  render {id}

document.on "DOMContentLoaded", ->
  window.sections = Array(document.querySelectorAll("body > div[id]")...).reverse()

document.on "scroll", (event) ->
  baseURL = location.toString().split("#")[0]
  div = window.sections.find (div) ->
    distance = div.offsetTop-window.scrollY-window.pointer.y
    distance < 1
  if div is undefined
    history.replaceState({}, "", "#{baseURL}") unless location.hash is undefined
    render {}
  else
    id = div.id
    history.replaceState({}, "", "#{baseURL}##{id}") unless location.hash is "##{id}"
    render {id}

render = (data) ->
  elem.classList.remove("selected") for elem in document.querySelectorAll("*.selected")
  if data.id
    elem.classList.add("selected") for elem in document.querySelectorAll("a[href='##{data.id}']")
    document.getElementById(data.id).classList.add("selected")
