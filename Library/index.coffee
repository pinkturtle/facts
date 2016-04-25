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

  # Doomed for relocation
  historyIndex: 0
  history: Immutable.List([Immutable.Set()])

  now: ->
    Facts.now()

  at: (max) ->
    if max is "now" then max = undefined
    Facts.database(this, {max, min:undefined})

  pull: (identifier) ->
    @query(where:(id) -> id is identifier)[0]

  query: (params={}) ->
    time = params["at"]
    delete params["at"]
    params["in"] = @at(time)
    Facts.query(params)

  transact: (inputData, time) ->
    Facts.transact(this, inputData, time)

  true: (id, mapOfValues) ->
    @transact([true, id, attribute, value] for attribute, value of mapOfValues)

  false: (id, mapOfValues) ->
    @transact([false, id, attribute, value] for attribute, value of mapOfValues)

  undefined: (id, mapOfValues) ->
    @transact([undefined, id, attribute, value] for attribute, value of mapOfValues)

# Extend Facts prototype with methods from Events.
Facts::[name] = value for name, value of require("./events")

# Define aliases for at.
Facts::database = Facts::asOf = Facts::at

# Define aliases for pull.
Facts::get = Facts::entity = Facts::recall = Facts::retrieve = Facts::pull

# Define aliases for query.
Facts::pleaseAnswerMyQuestion = Facts::query

# Define aliases for transact.
Facts::commit = Facts::pushState = Facts::transact

# Define aliases for true, false and undefined.
Facts::divert = Facts::assert  = Facts::add       = Facts::advance = Facts::true
Facts::revert = Facts::retract = Facts::subtract  = Facts::reverse = Facts::false
Facts::unsure                  = Facts::uncertain = Facts::unknown = Facts::undefined

# Expose Immutable for window authors.
Facts.Immutable = Immutable

# Define construct alias for the apply method.
Facts.construct = Facts.apply

Facts.now = require "./now"

Facts.database = require "./database"

Facts.query = require "./query"

Facts.transact = require "./transact"

# Export root-level constructor.
module.exports = Facts
