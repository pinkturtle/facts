{tape, Facts, Immutable} = require "./test_setup"

tape "Database Tests", (test) -> test.end()


tape "database is a Stack", (test) ->
  database = Facts().database()
  test.same database.constructor, Immutable.Stack
  test.end()


tape "database is initially empty", (test) ->
  database = Facts().database()
  test.same database.size, 0
  test.end()


tape "database contains true facts", (test) ->
  facts = Facts()
  facts.transact [[true,  "DC-59", "color", "Bronx Blue"]], 123
  test.same facts.database().toJS(), [
    [true, "DC-59", "color", "Bronx Blue", 123]
  ]
  test.end()


tape "database excludes false datoms", (test) ->
  facts = Facts()
  facts.transact [[false, "DC-59", "color", "Bronx Blue"]], 123
  test.same facts.datoms.toJS(), [
    [true,  "T123",  "time",  123,          123]
    [false, "DC-59", "color", "Bronx Blue", 123]
  ]
  test.same facts.database().size, 0
  test.end()


tape "database excludes untrue facts that were falsified", (test) ->
  facts = Facts()
  facts.transact [[true,  "DC-59", "color", "Bronx Blue"]], 123
  facts.transact [[false, "DC-59", "color", "Bronx Blue"]], 789
  test.same facts.datoms.toJS(), [
    [true,  "T789",  "time",  789,          789]
    [false, "DC-59", "color", "Bronx Blue", 789]
    [true,  "T123",  "time",  123,          123]
    [true,  "DC-59", "color", "Bronx Blue", 123]
  ]
  test.same facts.database().size, 0
  test.end()


tape "database excludes undefined datoms", (test) ->
  facts = Facts()
  facts.transact [[undefined, "DC-59", "color", "Bronx Blue"]], 123
  test.same facts.datoms.toJS(), [
    [true,      "T123",  "time",  123,         123]
    [undefined, "DC-59", "color", "Bronx Blue", 123]
  ]
  test.same facts.database().size, 0
  test.end()


tape "database excludes untrue facts that were previously true and are now unknown", (test) ->
  facts = Facts()
  facts.transact [[true,      "DC-59", "color", "Bronx Blue"]], 123
  facts.transact [[undefined, "DC-59", "color", "Bronx Blue"]], 789
  test.same facts.datoms.toJS(), [
    [true,      "T789",  "time",  789,          789]
    [undefined, "DC-59", "color", "Bronx Blue", 789]
    [true,      "T123",  "time",  123,          123]
    [true,      "DC-59", "color", "Bronx Blue", 123]
  ]
  test.same facts.database().size, 0
  test.end()


tape "database excludes transaction entity data", (test) ->
  facts = Facts()
  facts.transact [[true, "DC-59", "orientation", "left handed"]], 123
  test.same facts.datoms.toJS(), [
    [true, "T123",  "time",        123,           123]
    [true, "DC-59", "orientation", "left handed", 123]
  ]
  test.same facts.database().toJS(), [
    [true, "DC-59", "orientation", "left handed", 123]
  ]
  test.end()


tape "database at an instant excludes advancements that happened after", (test) ->
  facts = Facts()
  facts.transact [[true, "DC-59", "color", "Bronx Blue"]], 123
  facts.transact [[true, "DC-59", "color", "Black"]], 789
  test.same facts.at(123).toJS(), [
    [true, "DC-59", "color", "Bronx Blue", 123]
  ]
  test.same facts.at(789).toJS(), [
    [true, "DC-59", "color", "Black", 789]
  ]
  test.end()


tape "database entries are sorted by time", (test) ->
  facts = Facts()
  facts.transact [[true, "DC-59", "color", "Bronx Blue"]], 123
  facts.transact [[true, "DC-59", "orientation", "Left Handed"]], 456
  facts.transact [[true, "DC-59", "price", 499]], 789
  test.same facts.datoms.toJS(), [
    [true, "T789",  "time",        789,           789]
    [true, "DC-59", "price",       499,           789]
    [true, "T456",  "time",        456,           456]
    [true, "DC-59", "orientation", "Left Handed", 456]
    [true, "T123",  "time",        123,           123]
    [true, "DC-59", "color",       "Bronx Blue",  123]
  ]
  test.same facts.database().toJS(), [
    [true, "DC-59", "price",       499,           789]
    [true, "DC-59", "orientation", "Left Handed", 456]
    [true, "DC-59", "color",       "Bronx Blue",  123]
  ]
  test.end()


tape "database accepts now", (test) ->
  test.ok Facts().database("now")
  test.end()

tape "database accepts instants after the beginning of the epoch", (test) ->
  test.ok Facts().database(+1)
  test.end()

tape "database accepts the beginning of the epoch", (test) ->
  test.ok Facts().database(0)
  test.end()

tape "database accepts the instant before the beginning of the epoch", (test) ->
  test.ok Facts().database(-1)
  test.end()
