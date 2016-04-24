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

  untruthiness = filtered.filter (datom) -> datom.get(0) in [false, undefined]

  filtered = filtered.filter (datom) ->
    datomWasFalsified = untruthiness.find (untrue) ->
      (untrue.get(1) is datom.get(1)) and (untrue.get(2) is datom.get(2)) and (untrue.get(3) is datom.get(3)) and (untrue.get(4) >= datom.get(4))
    if datomWasFalsified
      return no
    else
      return yes

  sorted = []
  memo = {}
  filtered.forEach (datom) ->
    memo[datom.get(1)] ?= {}
    if memo[datom.get(1)][datom.get(2)] is undefined
      memo[datom.get(1)][datom.get(2)] = datom.get(3)
      sorted.push datom

  return Immutable.Stack(sorted)
