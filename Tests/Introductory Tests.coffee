{tape, Facts} = require "./test_setup"

tape "Introductory Tests", (test) -> test.end()

tape "construct function is available", (test) ->
  test.same typeof Facts.construct, "function"
  test.end()

tape "query function is available", (test) ->
  test.same typeof Facts.query, "function"
  test.end()

tape "instance of Facts has query function", (test) ->
  test.same typeof Facts().query, "function"
  test.end()

tape "instance of Facts has transact function", (test) ->
  test.same typeof Facts().transact, "function"
  test.end()

tape "instance of Facts has advance function", (test) ->
  test.same typeof Facts().advance, "function"
  test.end()

tape "instance of Facts has reverse function", (test) ->
  test.same typeof Facts().reverse, "function"
  test.end()

tape "instance of Facts has unknown function", (test) ->
  test.same typeof Facts().unknown, "function"
  test.end()

tape "instance of Facts has datoms", (test) ->
  test.same typeof Facts().datoms, "object"
  test.end()
