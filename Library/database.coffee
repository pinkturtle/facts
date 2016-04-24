Immutable = require "immutable"

module.exports = (facts, time) ->
  if time is "now" then time = undefined
  datoms = sample facts.datoms, {max:time, min:undefined}
  untruthiness = []
  mutant = []
  memo = {}
  datoms.forEach (datom) ->
    return if isTransaction(datom)
    return untruthiness.push(datom) if datom.get(0) in [false, undefined]
    return if untruthiness.some (untrue) -> match(untrue, datom) and (untrue.get(4) > datom.get(4))
    memo[datom.get(1)] ?= {}
    if memo[datom.get(1)][datom.get(2)] is undefined
      memo[datom.get(1)][datom.get(2)] = datom.get(3)
      mutant.push datom
  return Immutable.Stack(mutant)

sample = (datoms, range) ->
  switch
    when range.min is range.max is undefined
      datoms
    when range.max isnt undefined and range.min is undefined
      datoms.skipUntil (datom) -> datom.get(4) <= range.max
    when range.max is undefined and range.min isnt undefined
      datoms.takeWhile (datom) -> datom.get(4) >= range.min
    else
      datoms
        .skipUntil (datom) -> datom.get(4) <= range.max
        .takeWhile (datom) -> datom.get(4) >= range.min

isTransaction = (datom) -> isTransaction.pattern.test(datom.get(1))
isTransaction.pattern = /T[0-9]+/

match = (pattern, datom) ->
  (pattern.get(1) is datom.get(1)) and (pattern.get(2) is datom.get(2)) and (pattern.get(3) is datom.get(3))
