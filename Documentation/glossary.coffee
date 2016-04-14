# handle on time : facts.history
# want dequue for input
# want defer
# add new and remove without fear

# init data from local or remote. (safari)
# sync database to server and write to filesystem
# enable scroll handler

# Need facts to:
# - method for defining new ids

facts = Facts()
Immutable = Facts.Immutable

delegate = (event, procedure) ->
  document.addEventListener event, procedure, true

delegate2 = (event, host, procedure) ->
  document.querySelector(host).addEventListener event, procedure, true

document.on "DOMContentLoaded", (event) ->
  if serialized = localStorage.getItem("database")
    JSdatoms = JSON.parse(serialized)
    facts.datoms = Immutable.Stack Immutable.fromJS(JSdatoms)
    console.info "loaded glossary from localstorage", event.type, JSdatoms
    initialize()
  else
    d3.json "glossary.json", (json) ->
      facts.datoms = Immutable.Stack Immutable.fromJS(json)
      console.info "loaded glossary.json", json
      initialize()

initialize = ->
  console.info "initialize"
  facts.on "transaction", -> render()
  facts.on "transaction", saveDatabaseToLocalStorage
  facts.advance "glossary", words: ["value", "attribute", "entity", "database", "partition", "information", "outformation", "transaction", "fact", "datom", "query", "web agent"]

saveDatabaseToLocalStorage = ->
  localStorage.setItem("database", JSON.stringify(facts.database()))
  console.info "saved database to local storage", Date.now()

delegate2 "input", "form", (event) ->
  form = event.currentTarget
  window.requestAnimationFrame ->
    console.info requiredInputs = Array.apply undefined, form.querySelectorAll("[required]:not(:disabled)")
    console.info "in", input.name, input.value.trim() is "" for input in requiredInputs
    console.info "missing", missingInputs = (input for input in requiredInputs when input.value.trim() is "")
    if missingInputs.length is 0
      form.classList.remove("unacceptable")
      form.classList.add("acceptable")
    else
      form.classList.add("unacceptable")
      form.classList.remove("acceptable")

delegate "submit", (event) ->
  event.preventDefault()
  attributes =
    word: event.target.querySelector("[name=word]").value
    definition: event.target.querySelector("[name=definition]").value.replace(RegExp("<div>", "g"),"").replace(RegExp("</div>", "g"),"")
  facts.advance attributes.word, attributes
  glossary = facts.query(in:facts.history.last(), where:(id) -> id is "glossary")[0]
  facts.advance "glossary", words:glossary.words.concat(attributes.word)
  event.target.reset()


render = ->
  glossary = facts.query(in:facts.database(), where:(id) -> id is "glossary")[0]
  entities = facts.query in:facts.database(), where:(id) -> id in glossary.words
  sorted = entities.sort (a,b) ->
    if (a["entity id"] < b["entity id"]) then return -1
    if (a["entity id"] > b["entity id"]) then return +1
    return 0

  console.info "render", Date.now(), glossary.words, sorted

  div = d3.select("body").selectAll("div.definition").data(sorted, (entity) -> entity["entity id"])
  enter = div.enter()
    .insert("div").attr("class":"word", "id":((entity) -> entity["entity id"]), "data-id":((entity) -> entity["entity id"]))
    .html (entity) -> """
      <header>#{entity["entity id"]}</header>
      <div class="definition" contenteditable="plaintext-only" style="white-space: pre-wrap;">#{autolink(entity.definition, glossary)}</div>
      <input type="button" value="⌦" title="Take this word out of the Glossary">
    """
  enter.select("header").on
    "input": (entity) ->
      facts.advance entity["entity id"], "word": d3.event.target.innerHTML
  enter.select(".definition").on
    "input": (entity) ->
      console.info "entity", entity["entity id"], "definition": d3.event.target.innerText
      facts.advance entity["entity id"], "definition": d3.event.target.innerText
  enter.select("input[type=button]").on
    "mousedown": (entity) ->
      glossary = facts.query(in:facts.history.last(), where:(id) -> id is "glossary")[0]
      filtered = glossary.words.filter (word) -> word isnt entity.word
      facts.advance "glossary", "words": filtered
  exit = div.exit()
    .style "height", -> getComputedStyle(this)["height"]
    .style "opacity", -> getComputedStyle(this)["opacity"]
    .style "overflow", "hidden"
    .transition()
    .duration 222
    .style "opacity": 0
    .transition()
    .duration 222
    .style "height": "0px"
    .remove()

  link = d3.select("body > nav").selectAll("a[href]").data(sorted, (entity) -> entity["entity id"])
  link.enter()
    .insert("a").attr("href":(d)->"##{d["entity id"]}")
    .text (d)->d["entity id"]
  link.exit()
    .remove()

  row = d3.select("table.relevant.datoms tbody").selectAll("tr").data(facts.database().toJS())
  row.enter()
    .insert("tr").html (datom) -> """
      <td class="entity">#{datom[1]}</td>
      <td class="attribute">#{datom[2]}</td>
      <td class="value"><span>#{JSON.stringify(datom[3])}</span></td>
      <td class="transaction">#{datom[4]}</td>
    """
  row.html (datom) -> """
      <td class="entity">#{datom[1]}</td>
      <td class="attribute">#{datom[2]}</td>
      <td class="value"><span>#{JSON.stringify(datom[3])}</span></td>
      <td class="transaction">#{datom[4]}</td>
    """
  row.exit().remove()

  row = d3.select("table.all.datoms tbody").selectAll("tr").data(facts.datoms.toJS())
  row.enter()
    .insert("tr").html (datom) -> """
      <td class="entity">#{datom[1]}</td>
      <td class="attribute">#{datom[2]}</td>
      <td class="value"><span>#{JSON.stringify(datom[3])}</span></td>
      <td class="credence">#{datom[0]}</td>
      <td class="transaction">#{datom[4]}</td>
    """
  row.html (datom) -> """
      <td class="entity">#{datom[1]}</td>
      <td class="attribute">#{datom[2]}</td>
      <td class="value"><span>#{JSON.stringify(datom[3])}</span></td>
      <td class="credence">#{datom[0]}</td>
      <td class="transaction">#{datom[4]}</td>
    """
  row.exit().remove()

  # d3.select("pre.serialized.database").text JSON.stringify(relevantSet, undefined, "  ")


sortByTransactionTime = (a, b) ->
  b.transaction["record time"] - a.transaction["record time"]


autolink = (string, glossary) ->
  words = d3.set(string.match(/\w+/g).map (word) -> word.toLowerCase()).values()
  glossaryWords = (word for word in words when word in glossary.words)
  newString = ""+string
  glossaryWords.forEach (word) ->
    newString = newString.replace(RegExp(word, "g"), """<a class="word" href="##{word}">#{word}</a>""")
  return newString

# Select a section of the page within the window frame and under the mouse pointer.

selectableElements = "body > div[id]"

renderSelectedSection = (data) ->
  selected.classList.remove("selected") for selected in document.querySelectorAll("*.selected")
  if data.id
    document.querySelector("a[href='##{data.id}']").classList.add("selected")
    document.getElementById(data.id).classList.add("selected")

document.addEventListener "DOMContentLoaded", (event) ->
  window.pointer = {x:0, y:0}

document.addEventListener "mousemove", (event) ->
  window.pointer = {x: event.clientX, y: event.clientY}
  if element = event.srcElement.closest(selectableElements)
    baseURL = location.toString().split("#")[0]
    history.replaceState({}, "", "#{baseURL}##{element.id}") unless location.hash is "##{element.id}"
    renderSelectedSection {id: element.id}

document.addEventListener "scroll", (event) ->
  sections = Array.from(document.querySelectorAll(selectableElements))
  baseURL = location.toString().split("#")[0]
  div = sections.reverse().find (div) ->
    distance = div.offsetTop-window.scrollY-window.pointer.y
    distance < 1
  if div is undefined
    history.replaceState({}, "", "#{baseURL}") unless location.hash is undefined
    renderSelectedSection {}
  else
    id = div.id
    history.replaceState({}, "", "#{baseURL}##{id}") unless location.hash is "##{id}"
    renderSelectedSection {id}
