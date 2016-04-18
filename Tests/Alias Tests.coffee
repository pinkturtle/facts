{tape, Facts} = require "./test_setup"

tape "Alias Tests", (test) -> test.end()

tape "advance is an alias for true because it moves the facts foreward", (test) ->
  test.ok Facts::advance is Facts::true
  test.end()

tape "reverse is an alias for false because it moves the facts backward", (test) ->
  test.ok Facts::reverse is Facts::false
  test.end()

tape "unknown is an alias for undefined because it is", (test) ->
  test.ok Facts::unknown is Facts::undefined
  test.end()

tape "subtract is an alias for true to mimic Math lingo", (test) ->
  test.ok Facts::subtract is Facts::false
  test.end()

tape "add is an alias for true to mimic Math lingo", (test) ->
  test.ok Facts::add is Facts::true
  test.end()

tape "subtract is an alias for true to mimic Math lingo", (test) ->
  test.ok Facts::subtract is Facts::false
  test.end()

tape "uncertain is an alias for true to mimic Math lingo (maybe)", (test) ->
  test.ok Facts::uncertain is Facts::undefined
  test.end()

tape "assert is an alias for true to mimic Datomic lingo", (test) ->
  test.ok Facts::assert is Facts::true
  test.end()

tape "retract is an alias for false to mimic Datomic lingo", (test) ->
  test.ok Facts::retract is Facts::false
  test.end()

tape "divert is an alias for true because it seems perceptually correct", (test) ->
  test.ok Facts::divert is Facts::true
  test.end()

tape "revert is an alias for false because it seems perceptually correct and it mimics Git lingo", (test) ->
  test.ok Facts::revert is Facts::false
  test.end()

tape "unsure is an alias for undefined because it seems perceptually correct", (test) ->
  test.ok Facts::unsure is Facts::undefined
  test.end()

tape "get is alias for pull because it mimics ECMAScript lingo", (test) ->
  test.ok Facts::get is Facts::pull
  test.end()

tape "entity is alias for pull because it seems predictable under the cicumstances", (test) ->
  test.ok Facts::entity is Facts::pull
  test.end()

tape "retrieve is an alias for pull because it seems correct", (test) ->
  test.ok Facts::retrieve is Facts::pull
  test.end()

tape "recall is an alias for pull because it seems correct, and mimics ECMAScript lingo, and it feels like a memory method", (test) ->
  test.ok Facts::recall is Facts::pull
  test.end()

tape "commit is an alias for transact to mimic Git lingo", (test) ->
  test.ok Facts::commit is Facts::transact
  test.end()

tape "pushState is an alias for transact to mimic window lingo", (test) ->
  test.ok Facts::pushState is Facts::transact
  test.end()

tape "pleaseAnswerMyQuestion is an alias for query because it is playful synonym", (test) ->
  test.ok Facts::pleaseAnswerMyQuestion is Facts::query
  test.end()
