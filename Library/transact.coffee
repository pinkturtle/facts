Immutable = require "immutable"

module.exports = (facts, input, instant=facts.now()) ->
  novelty = Immutable.List(validate(input)).map (values) -> Datom.fromInput(values, instant)
  transactionDatom = Datom true, "T#{instant}", "undecided", undefined, instant
  facts.datoms = facts.datoms.unshiftAll(novelty).unshift(transactionDatom)
  dispatch facts, "transaction", report =
    datoms: novelty
    instant: instant
    product: facts.database()
    transaction: "T#{instant}"

Datom = (fact, identifier, attribute, value, instant) ->
  Immutable.List.of fact, identifier, attribute, value, instant

Datom.fromInput = (values, instant) ->
  Datom values[0], values[1], values[2], Immutable.fromJS(values[3]), instant

dispatch = (facts, event, report) ->
  setTimeout((-> facts.dispatch("transaction", report)), 1)
  return report

validate = (input) ->
  # Abort if input does not map.
  if typeof input?.map isnt "function"
    throw """
      Facts.transact can’t create a transaction without a list of input.
    """
  # Abort if input is empty.
  if input.length is 0
    throw """
      Facts.transact can’t create a transaction with an empty list of input data.
    """
  # Abort if input specifies an unrecognized operation.
  unrecognizedOperations = input.filter(isUnrecognizedOperation).map((data) -> data[0])
  if unrecognizedOperations.length isnt 0
    throw """
      Oops! '#{unrecognizedOperations.first}' is not a recognized transaction operation. Try true, false or undefined.
    """
  # Abort if input specifies for operations on transactions.
  transactions = input.filter(identifiesTransaction).map((data) -> data[1])
  if transactions.length isnt 0
    someTransactions = if transactions.length is 1 then "another transaction" else "#{transactions.length} other transactions"
    throw """
      Transaction was aborted because its input contained data that identified #{someTransactions}: #{transactions.join(" ")}

      Transactions may not be explicitly advanced, reversed or unknown because Facts relies on
      them as its implicit record of what happened when. Facts.transact is the only function
      permitted to construct transactions. Transaction data from other sources will be rejected.
  """
  return input

identifiesTransaction = (datom) -> identifiesTransaction.pattern.test(datom[1])
identifiesTransaction.pattern = /T[0-9]+/

recognizedOperations = [true, false, undefined]
isUnrecognizedOperation = (datom) -> datom[0] in recognizedOperations is false
