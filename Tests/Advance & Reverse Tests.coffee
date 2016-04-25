{tape, Facts} = require "./test_setup"
Immutable = require "immutable"

tape "Advance & Reverse Tests", (test) -> test.end()

tape "A brief history of Richard Hickey", (test) ->
  facts = Facts()

  findRichard = ->
    entities = facts.query where:(id) -> id is 1
    test.same entities.length, 1
    return entities[0]

  # He was born undecided with the name Richard Hickey.
  facts.advance 1, "name":"Richard Hickey", "title":"Undecided"
  # He was known as Richard Hickey, Undecided.
  test.same findRichard(), "id":1, "name":"Richard Hickey", "title":"Undecided"

  # In time, he matured.
  facts.advance 1, "name":"Dick Hickey", "title":"Smooth Operator"
  # He was known as Dick Hickey, Smooth Operator.
  test.same findRichard(), "id":1, "name":"Dick Hickey", "title":"Smooth Operator"

  # Later he adandoned the  Dick part of his name.
  facts.reverse 1, "name":"Dick Hickey"
  # He was known as Richard Hickey, Smooth Operator.
  test.same findRichard(), "id":1, "name":"Richard Hickey", "title":"Smooth Operator"

  # Later he abandoned the dickish "title" also.
  facts.reverse 1, "title":"Smooth Operator"
  # He was once again known as Richard Hickey, Undecided.
  test.same findRichard(), "id": 1, "name":"Richard Hickey", "title":"Undecided"

  # Richard decided to make some money so he changed his name again
  # and redefined himself as a Datom Farmer.
  facts.advance 1, "name": "Rich Hickey", "title":"Datom Farmer"
  # From then on he was known as Rich Hickey, Datom Farmer.
  test.same findRichard(), "id":1, "name":"Rich Hickey", "title":"Datom Farmer"

  test.end()

tape "advance to establish a new perception of the facts", (test) ->
  facts = Facts()
  facts.advance 1, "name": "Richard"
  entities = facts.query where:(id) -> id is 1
  test.same entities.constructor, Array
  test.same entities.length, 1
  test.same entities[0], { "name": "Richard", "id": 1 }
  test.end()

tape "reverse to reclaim the previous perception of the facts", (test) ->
  facts = Facts()
  facts.advance 1, "name": "Richard Hickey"
  facts.advance 1, "name": "Dick Hickey"
  facts.reverse 1, "name": "Dick Hickey"
  entities = facts.query where:(id) -> id is 1
  test.same entities.constructor, Array
  test.same entities.length, 1
  test.same entities[0], { "name": "Richard Hickey", "id": 1 }
  test.end()

tape "advance after reverse", (test) ->
  facts = Facts()
  facts.advance 1, "name": "Richard Hickey"
  facts.advance 1, "name": "Dick Hickey"
  facts.reverse 1, "name": "Dick Hickey"
  facts.advance 1, "name": "Rich Hickey"
  entities = facts.query where:(id) -> id is 1
  test.same entities.constructor, Array
  test.same entities.length, 1
  test.same entities[0], { "name": "Rich Hickey", "id": 1 }
  test.end()

tape "advance returns transaction report", (test) ->
  report = Facts().advance 1, en: "Hello World!"
  test.same Object.keys(report), ["datoms", "instant", "product", "transaction"]
  test.end()

tape "reverse returns transaction report", (test) ->
  report = Facts().reverse 1, en: "Hello Wrrld!"
  test.same Object.keys(report), ["datoms", "instant", "product", "transaction"]
  test.end()
