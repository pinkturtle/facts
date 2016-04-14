{tape, Facts} = require "./test_setup"

tape "Value Tests", (test) -> test.end()

tape "transact Array value", (test) ->
  facts = Facts()
  facts.transact [
    ["advance", 1, "array value", [1, 2, 3]]
  ]
  entity = facts.query(where:(id)->1)[0]
  test.same entity["array value"].constructor, Array
  test.same entity["array value"], [1, 2, 3]
  test.end()

tape "advance Array value", (test) ->
  facts = Facts()
  facts.advance 1, "array value": [1, 2, 3]
  entity = facts.query(where:(id)->1)[0]
  test.same entity["array value"].constructor, Array
  test.same entity["array value"], [1, 2, 3]
  test.end()

tape "transact String value", (test) ->
  facts = Facts()
  facts.transact [
    ["advance", 1, "string value", "1, 2, 3"]
  ]
  entity = facts.query(where:(id)->1)[0]
  test.same entity["string value"].constructor, String
  test.same entity["string value"], "1, 2, 3"
  test.end()

tape "advance String value", (test) ->
  facts = Facts()
  facts.advance 1, "string value": "1, 2, 3"
  entity = facts.query(where:(id)->1)[0]
  test.same entity["string value"].constructor, String
  test.same entity["string value"], "1, 2, 3"
  test.end()

tape "transact Number value", (test) ->
  facts = Facts()
  facts.transact [
    ["advance", 1, "numeric value", 1]
  ]
  entity = facts.query(where:(id)->1)[0]
  test.same entity["numeric value"].constructor, Number
  test.same entity["numeric value"], 1
  test.end()

tape "advance Number value", (test) ->
  facts = Facts()
  facts.advance 1, "numeric value": 1
  entity = facts.query(where:(id)->1)[0]
  test.same entity["numeric value"].constructor, Number
  test.same entity["numeric value"], 1
  test.end()
