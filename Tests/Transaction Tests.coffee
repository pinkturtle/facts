{tape, Facts, Immutable} = require "./test_setup"

tape "Transaction Tests", (test) -> test.end()

tape "transactions are monotonic", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, i, yes] ] for i in [100..0]
  database = facts.database()
  transactionSet = Immutable.Set(database.map (datom) -> datom.get(4))
  test.same database.size, transactionSet.size
  test.end()

tape "transaction report has expected keys", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  test.same Object.keys(report), ["transaction", "db before", "db after", "data"]
  test.end()

tape "report includes references to the value of the database before and after the transaction", (test) ->
  facts = Facts()
  databaseBeforeTransaction = facts.history.last()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  databaseAfterTransaction = facts.history.last()
  test.equal report["db before"], databaseBeforeTransaction
  test.equal report["db before"].hashCode(), databaseBeforeTransaction.hashCode()
  test.equal report["db after"], databaseAfterTransaction
  test.equal report["db after"].hashCode(), databaseAfterTransaction.hashCode()
  test.end()

tape "a transaction generates a new entry in the database history", (test) ->
  facts = Facts()
  test.same facts.history.count(), 1
  facts.transact [
    [true, 1, "en", "Hello world!"]
    [true, 1, "en", "Goodbye moon"]
  ]
  test.same facts.history.count(), 2
  test.end()

tape "subsequent transaction generate new entries in the database history", (test) ->
  facts = Facts()
  test.same facts.history.count(), 1
  facts.transact [[true, 1, "en", "Hello world!"]]
  test.same facts.history.count(), 2
  facts.transact [[true, 2, "en", "Goodbye moon"]]
  test.same facts.history.count(), 3
  test.end()

tape "transact one advancement", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ]
  test.same facts.history.count(), 2
  test.end()

tape "transact one reversal", (test) ->
  facts = Facts()
  report = facts.transact [ [false, 1, "name", "Ursula Franklan"] ]
  test.same facts.history.count(), 2
  test.end()

tape "transact one unknown", (test) ->
  facts = Facts()
  report = facts.transact [ [undefined, 1, "nickname", "Frankly"] ]
  test.same facts.history.count(), 2
  test.end()


tape "last transaction is at the beginning of the stack of datoms", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklen"] ], 456
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 789
  test.same facts.datoms.first().toJS()[4], "T789"
  test.end()

tape "first transaction is at the end of the stack of datoms", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklen"] ], 456
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 789
  test.same facts.datoms.last().toJS()[4], "T123"
  test.end()

tape "transact raw access", (test) ->
  facts = Facts()
  report = facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 123
  test.same facts.history.count(), 2
  test.same facts.datoms.toJS(), [
    [ true, "T123", 'time', 123,               'T123' ]
    [ true, 1,      'name', 'Ursula Franklin', 'T123' ]
  ]
  test.end()

tape "database value after transaction", (test) ->
  facts = Facts()
  facts.transact [ [true, 1, "name", "Ursula Franklan"] ], 123
  facts.transact [ [true, 1, "name", "Ursula Franklin"] ], 456
  test.same facts.database(123).toJS(), [
    [ true, 1, 'name', 'Ursula Franklan', 'T123' ]
  ]
  test.same facts.database(456).toJS(), [
    [ true, 1, 'name', 'Ursula Franklin', 'T456' ]
  ]
  test.end()
