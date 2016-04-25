{tape, Facts} = require "./test_setup"

tape "Pull Tests", (test) -> test.end()

tape "pull returns entity identified by identifier", (test) ->
  facts = Facts()
  facts.transact [[true, 1, "en", "Hello world!"]]
  test.same facts.pull(1), { en:"Hello world!", id: 1 }
  test.end()

tape "pull returns undefined when it receives an unknown identifier", (test) ->
  test.same Facts().pull(undefined), undefined
  test.end()

tape "pull from specific database, and current database", (test) ->
  facts = Facts()
  initialDatabase = facts.database()
  facts.transact [[true, 1, "en", "Hello world!"]]
  secondDatabase = facts.database()
  facts.transact [[true, 1, "en", "HELLO WORLD!!!"]]
  thirdDatabase = facts.database()
  test.same facts.pull(1, from:[initialDatabase]), undefined
  test.same facts.pull(1, from:[secondDatabase]), { en:"Hello world!", id: 1 }
  test.same facts.pull(1, from:[thirdDatabase]), { en:"HELLO WORLD!!!", id: 1 }
  test.same facts.pull(1), { en:"HELLO WORLD!!!", id: 1 }
  test.end()
