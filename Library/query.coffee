Immutable = require "immutable"

module.exports = (options) ->
  database = options["in"]
  output = options["out"] ? "list"
  map = {}

  if options["where"]
    database = database.filter (datom) ->
      options["where"](datom.get(1), datom.get(2), datom.get(3))

  entities = database.reduce mapEachDatom, {}

  if output is "map"
    return entities

  if output is "list"
    return (entity for id, entity of entities)

  throw "'#{output}' is not a recognized query output format. Try out:'list' or out:'map'."

mapEachDatom = (map, datom) ->
  map[datom.get(1)] ?= {}
  map[datom.get(1)]["id"] = datom.get(1)
  map[datom.get(1)][datom.get(2)] = if (value = datom.get(3)).toJS? then value.toJS() else value
  return map
