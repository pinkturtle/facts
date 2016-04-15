Events = require("./events")
Immutable = window?["Immutable"] or require("immutable")

class Facts
  constructor: ->
    if this instanceof Facts
      @initialize()
      return this
    else
      return new Facts

  initialize: ->

  datoms: Immutable.Stack()

  historyIndex: 0

  history: Immutable.List([Immutable.Set()])

  at: (instant) ->
    Facts.database(this, instant)

  query: (params={}) ->
    time = params["at"]
    delete params["at"]
    params["in"] = @at(time)
    Facts.query(params)

  pull: (identifier) ->
    @query(where:(id) -> id is identifier)[0]

  advance: (id, mapOfValues) ->
    @transact(["advance", id, attribute, value] for attribute, value of mapOfValues)

  reverse: (id, mapOfValues) ->
    @transact(["reverse", id, attribute, value] for attribute, value of mapOfValues)

  unknown: (id, mapOfValues) ->
    @transact(["unknown", id, attribute, value] for attribute, value of mapOfValues)

  transact: (inputData, time) ->
    Facts.transact(this, inputData, time)

# Extend Facts prototype with methods from Events.
Facts::[name] = value for name, value of require("./events")

# Define aliases for at.
Facts::database = Facts::asOf = Facts::at

# Define aliases for advance and reverse.
Facts::divert = Facts::assert  = Facts::add      = Facts::advance
Facts::revert = Facts::retract = Facts::subtract = Facts::reverse
Facts::unsure                                    = Facts::unknown

# Define aliases for pull.
Facts::get = Facts::entity = Facts::recall = Facts::retrieve = Facts::pull

# Define aliases for transact.
Facts::commit = Facts::pushState = Facts::transact

# Expose Immutable for window authors.
Facts.Immutable = Immutable

# Define construct alias for the apply method.
Facts.construct = Facts.apply

Facts.database = require "./database"

Facts.query = require "./query"

Facts.transact = require "./transact"

# Export root-level constructor.
module.exports = Facts
