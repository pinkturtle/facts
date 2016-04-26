{tape, Facts, Immutable} = require "./test_setup"

tape "Transaction Tests", (test) -> test.end()

tape "transactions are constructed with monotonic integrity", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, i, yes] ] for i in [100..0]
  database = facts.database()
  transactionSet = Immutable.Set(database.map (datom) -> datom.get(4))
  test.same database.size, transactionSet.size
  test.end()

tape "can’t transact advancement of a transaction", (test) ->
  test.exception "Transaction was aborted because its input contained data that identified a transaction", ->
    Facts().transact [ [true, "T123", "attribute", "value"] ]
  test.end()

tape "transaction report has expected keys", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  test.same Object.keys(report), ["datoms", "instant", "product", "transaction"]
  test.end()

tape "report includes instant", (test) ->
  report = Facts().transact [ [true, "ok", "yes", "please"] ], 123
  test.same report.instant, 123
  test.end()

tape "report includes list of novel datoms", (test) ->
  report = Facts().transact [ [true, "ok", "yes", "please"] ], 123
  test.same report.datoms.constructor, Immutable.List
  test.same report.datoms.size, 1
  test.same report.datoms.toJS(), [
    [true, "ok", "yes", "please", 123]
  ]
  test.end()

tape "report includes its product: the value of the database after the transaction", (test) ->
  facts = Facts()
  databaseBeforeTransaction = facts.database()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  test.ok report.product.equals(facts.database("now"))
  test.ok report.product.equals(databaseBeforeTransaction) is false
  test.end()

tape "report includes transaction", (test) ->
  report = Facts().transact [ [true, "ok", "yes", "please"] ], 123
  test.ok report.transaction, "T123"
  test.end()

tape "transact one advancement", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  test.same facts.datoms.count(), 2
  test.end()

tape "transact one reversal", (test) ->
  facts = Facts()
  report = facts.transact [ [false, 1, "name", "Ursula Franklan"] ]
  test.same facts.datoms.count(), 2
  test.end()

tape "transact one unknown", (test) ->
  facts = Facts()
  report = facts.transact [ [undefined, 1, "nickname", "Frankly"] ]
  test.same facts.datoms.count(), 2
  test.end()

tape "last transaction is at the beginning of the stack of datoms", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklen"] ], 456
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 789
  test.same facts.datoms.first().toJS()[4], 789
  test.end()

tape "first transaction is at the end of the stack of datoms", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklen"] ], 456
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 789
  test.same facts.datoms.last().toJS()[4], 123
  test.end()

tape "transact raw access", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 123
  test.same facts.datoms.toJS(), [
    [ true, "T123", "undecided", undefined,         123 ]
    [ true, 1,      "name",      "Ursula Franklin", 123 ]
  ]
  test.end()

tape "database value after transaction", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 456
  test.same facts.database(123).toJS(), [
    [ true, 1, 'name', 'Ursula Franklan', 123 ]
  ]
  test.same facts.database(456).toJS(), [
    [ true, 1, 'name', 'Ursula Franklin', 456 ]
  ]
  test.end()
