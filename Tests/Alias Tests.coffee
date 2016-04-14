{tape, Facts} = require "./test_setup"

tape "Alias Tests", (test) -> test.end()

tape "add is an alias for advance to mimic Math lingo", (test) ->
  test.ok Facts::add is Facts::advance
  test.end()

tape "subtract is an alias for advance to mimic Math lingo", (test) ->
  test.ok Facts::subtract is Facts::reverse
  test.end()

tape "assert is an alias for advance to mimic Datomic lingo", (test) ->
  test.ok Facts::assert is Facts::advance
  test.end()

tape "retract is an alias for reverse to mimic Datomic lingo", (test) ->
  test.ok Facts::revert is Facts::reverse
  test.end()

tape "divert is an alias for advance because it feels good", (test) ->
  test.ok Facts::revert is Facts::reverse
  test.end()

tape "revert is an alias for reverse because it feels good", (test) ->
  test.ok Facts::revert is Facts::reverse
  test.end()

tape "unsure is an alias for unknown because it feels good", (test) ->
  test.ok Facts::unsure is Facts::unknown
  test.end()

tape "get is alias for pull because it mimics ECMAScript lingo", (test) ->
  test.ok Facts::get is Facts::pull
  test.end()

tape "retrieve is an alias for pull because it seems correct", (test) ->
  test.ok Facts::retrieve is Facts::pull
  test.end()

tape "recall is an alias for pull because it seems correct, and mimics ECMAScript lingo, and it feels like a memory method", (test) ->
  test.ok Facts::recall is Facts::pull
  test.end()
