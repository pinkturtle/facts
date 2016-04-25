{Map, List} = Immutable = require "immutable"

module.exports = (params) ->
  database = params.in[0]
  output = params.out ? Array
  if params.where
    database = database.filter (datom) ->
      params.where datom.get(1), datom.get(2), datom.get(3), datom.get(4)
  entities = database.reduce mapEachDatom, {}
  switch (params.out ? Array)
    when Array then (entity for id, entity of entities)
    when List then List(entity for id, entity of entities)
    when Map then Map(entities)
    when Object then entities
    else throw "Oops! #{JSON.stringify(params.out)} is not a recognized query output format."

mapEachDatom = (map, datom) ->
  map[datom.get(1)] ?= {}
  map[datom.get(1)]["id"] = datom.get(1)
  map[datom.get(1)][datom.get(2)] = if (value = datom.get(3)).toJS? then value.toJS() else value
  return map
