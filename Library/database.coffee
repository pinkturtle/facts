Immutable = require "immutable"

module.exports = (facts, rangeOfTime) ->
  sample = takeSampleOf facts.datoms, rangeOfTime
  reduction = sample.reduce toTruth(), Immutable.fromJS(datoms:[], entities:{})
  database = Immutable.Stack(reduction.get("datoms"))
  database.entities = reduction.get("entities")
  return database


takeSampleOf = (datoms, range) ->
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


toTruth = ->
  untrue = [false, undefined]
  untruthiness = []
  return (memo, datom, key) ->
    return memo if isTransaction(datom)
    return memo if datom.get(0) in untrue and untruthiness.push(datom)
    return memo if untruthiness.some (untrue) -> match(untrue, datom) and (untrue.get(4) > datom.get(4))
    return memo if memo.hasIn ["entities", datom.get(1), datom.get(2)]
    return memo
      .setIn ["datoms"], memo.get("datoms").push(datom)
      .setIn ["entities", datom.get(1), datom.get(2)], datom.get(3)


isTransaction = (datom) -> isTransaction.pattern.test(datom.get(1))
isTransaction.pattern = /T[0-9]+/


match = (pattern, datom) ->
  (pattern.get(1) is datom.get(1)) and (pattern.get(2) is datom.get(2)) and (pattern.get(3) is datom.get(3))
