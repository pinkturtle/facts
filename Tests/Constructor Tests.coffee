{tape, Facts} = require "./test_setup"

tape "Constructor Tests", (test) -> test.end()

assertInstanceIsOK = (facts, test) ->
  test.ok facts instanceof Facts
  test.ok facts.query
  test.ok facts.datoms
  test.ok facts.history

tape "construct instance without 'new' operator", (test) ->
  facts = Facts()
  assertInstanceIsOK facts, test
  test.end()

tape "construct instance with 'new' operator", (test) ->
  facts = new Facts
  assertInstanceIsOK facts, test
  test.end()

tape "construct instance with 'call' method", (test) ->
  facts = Facts.call()
  assertInstanceIsOK facts, test
  test.end()

tape "construct instance with 'apply' method", (test) ->
  facts = Facts.apply()
  assertInstanceIsOK facts, test
  test.end()

tape "construct instance with 'construct' method", (test) ->
  facts = Facts.construct()
  assertInstanceIsOK facts, test
  test.end()
