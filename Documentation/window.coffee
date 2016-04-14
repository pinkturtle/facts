if location.hostname is "pinkturtle.github.io" and location.protocol isnt "https:"
  window.location = location.toString().replace("http:", "https:")

Number::millisecond = Number::milliseconds = -> @valueOf()
Number::second      = Number::seconds      = -> @milliseconds() * 1000
Number::minute      = Number::minutes      = -> @seconds() * 60
Number::hour        = Number::hours        = -> @minutes() * 60

Function.delay = (amount, procedure) -> setTimeout(procedure, amount)
Function.defer = (procedure) -> setTimeout(procedure, 1)

Function::delay = (amount) -> Function.delay(amount, this)
Function::defer = -> Function.defer(this)

document.initialized = Date.now()

document.pull = document.querySelector

document.query = (selector) ->
  Array.from(document.querySelectorAll(selector))

document.on = (eventname, selector, procedure) ->
  if selector instanceof Function
    procedure = selector
    selector = undefined
  if selector
    wrapped = (event) ->
      if element = event.target.closest(selector)
        procedure(event, element)
  else
    wrapped = procedure
  document.addEventListener eventname, wrapped

document.on "DOMContentLoaded", ->
  console.info "document object model is ready", Date.now() - document.initialized

window.addEventListener "load", ->
  console.info "window has loaded", Date.now() - document.initialized

window.pointer = {x:0, y:0}

document.on "DOMContentLoaded", ->
  window.pointer = {x:0, y:0}

document.on "mousemove", (event) ->
  window.pointer = {x: event.clientX, y: event.clientY}
