{tape, Facts} = require "./test_setup"

tape "Pull Tests", (test) -> test.end()

tape "pull returns entity identified by id", (test) ->
  facts = Facts()
  facts.transact [["advance", 1, "en", "Hello world!"]]
  test.same facts.pull(1), { "en": "Hello world!", "id": 1 }
  test.end()

tape "pull returns undefined when it receives an unknown identier", (test) ->
  test.same Facts().pull(undefined), undefined
  test.end()
