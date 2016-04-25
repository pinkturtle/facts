Immutable = require "immutable"

module.exports = (options) ->
  database = options["in"]
  output = options["out"] ? Array

  if options["where"]
    database = database.filter (datom) ->
      options["where"](datom.get(1), datom.get(2), datom.get(3))

  entities = database.reduce mapEachDatom, {}

  if output is Object
    return entities

  if output is Array
    return (entity for id, entity of entities)

  throw "Oops! #{JSON.stringify(output)} is not a recognized query output format. Try query({out:Array}) or query({out:Object})"

mapEachDatom = (map, datom) ->
  map[datom.get(1)] ?= {}
  map[datom.get(1)]["id"] = datom.get(1)
  map[datom.get(1)][datom.get(2)] = if (value = datom.get(3)).toJS? then value.toJS() else value
  return map
