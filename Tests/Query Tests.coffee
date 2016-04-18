{tape, Facts} = require "./test_setup"

tape "Query Tests", (test) -> test.end()

tape "query returns a list of entities when no output format is specified", (test) ->
  entities = Facts.query in:Facts().database()
  test.same entities.constructor, Array
  test.end()

tape "query returns a list of entities when specified", (test) ->
  entities = Facts.query in:Facts().database(), out:"list"
  test.same entities.constructor, Array
  test.end()

tape "query returns a map of entities when specified", (test) ->
  entities = Facts.query in:Facts().database(), out:"map"
  test.same entities.constructor, Object
  test.end()

tape "query throws an exception when an unrecognized output format is specified", (test) ->
  executeQueryWithUnrecognizedOutputFormat = ->
    Facts.query in:Facts().database(), out:"turtle food"
  test.throws executeQueryWithUnrecognizedOutputFormat, /is not a recognized query output format/
  test.end()

tape "query for one entity returns a one item list", (test) ->
  facts = Facts()
  facts.transact [[true, 1, "en", "Hello world!"]]
  entities = Facts.query in:facts.database(), where:(id) -> id is 1
  test.same entities.length, 1
  test.same entities[0], { "en": "Hello world!", "id": 1 }
  test.end()

tape "query for all entities returns list of all entities", (test) ->
  facts = Facts()
  facts.transact [
    [true, 1, "en", "Hello world!"]
    [true, 2, "en", "Goodbye moon"]
  ]
  entities = Facts.query in:facts.database()
  test.same entities.length, 2
  test.same entities[0], { "en": "Hello world!", "id": 1 }
  test.same entities[1], { "en": "Goodbye moon", "id": 2 }
  test.end()

tape "query results are entity maps of all known attributes", (test) ->
  facts = Facts()
  facts.transact [
    [true, 1, "en", "Hello world!"]
    [true, 1, "fr", "Salut le monde!"]
  ]
  entities = Facts.query in:facts.database(), where:(id) -> id is 1
  entity = entities[0]
  test.same Object.keys(entity), ["id", "en", "fr"]
  test.same entity["en"], "Hello world!"
  test.same entity["fr"], "Salut le monde!"
  test.end()
