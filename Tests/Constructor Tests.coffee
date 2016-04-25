{tape, Facts, Immutable} = require "./test_setup"

tape "Constructor Tests", (test) -> test.end()

tape "construct instance without datoms", (test) ->
  facts = Facts()
  test.same facts.datoms.size, 0
  test.end()

tape "construct instance with stack of datoms", (test) ->
  source = Facts(now:-> 123)
  source.advance 1, en:"Hello World!"
  constructed = Facts datoms:source.datoms
  test.same constructed.datoms.size, 2
  test.same constructed.datoms.toJS(), [
    [true, "T123", "undecided", undefined,      123]
    [true, 1,      "en",        "Hello World!", 123]
  ]
  test.end()

tape "construct instance with array of datoms", (test) ->
  source = Facts(now:-> 123)
  source.advance 1, en:"Hello World!"
  constructed = Facts datoms:source.datoms.toArray()
  test.same constructed.datoms.size, 2
  test.same constructed.datoms.toJS(), [
    [true, "T123", "undecided", undefined,      123]
    [true, 1,      "en",        "Hello World!", 123]
  ]
  test.end()

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

assertInstanceIsOK = (facts, test) ->
  test.ok facts instanceof Facts
  test.ok facts.datoms
