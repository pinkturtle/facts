Immutable = require "immutable"

module.exports = (facts, time) ->
  if time is "now" then time = undefined

  # Filter out transaction entities
  filtered = facts.datoms.filterNot (datom) ->
    /T[0-9]+/.test(datom.get(1))

  # Select relevant datoms for specified time.
  if time
    filtered = filtered.filter (datom) ->
      time >= datom.get(4)

  # Filter out datoms that have been redacted.
  retractions = filtered.filter (datom) -> datom.get(0) is false
  filtered = filtered.filter (datom) ->
    datomWasRetracted = retractions.find (retraction) ->
      (retraction.get(1) is datom.get(1)) and (retraction.get(2) is datom.get(2)) and (retraction.get(3) is datom.get(3)) and (retraction.get(4) >= datom.get(4))
    if datomWasRetracted
      return no
    else
      return yes

  collected = Immutable.Set()
  memo = {}
  filtered.forEach (datom) ->
    memo[datom.get(1)] ?= {}
    if memo[datom.get(1)][datom.get(2)] is undefined
      memo[datom.get(1)][datom.get(2)] = datom.get(3)
      collected = collected.add(datom)

  return collected
