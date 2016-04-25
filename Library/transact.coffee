Immutable = require "immutable"

module.exports = (facts, inputData, instant=facts.now()) ->
  if typeof inputData?.map isnt "function"
    throw """
      Facts.transact can’t create a transaction without a list of input.
    """

  if inputData.length is 0
    throw """
      Facts.transact can’t create a transaction with an empty list of input data.
    """

  # Abort if input specifies for operations on transactions.
  transactions = inputData.filter(identifiesTransaction).map((data) -> data[1])
  if transactions.length isnt 0
    someTransactions = if transactions.length is 1 then "another transaction" else "#{transactions.length} other transactions"
    throw """
      Transaction was aborted because its input contained data that identified #{someTransactions}: #{transactions.join(" ")}

      Transactions may not be explicitly advanced, reversed or unknown because Facts relies on
      them as its implicit record of what happened when. Facts.transact is the only function
      permitted to construct transactions. Transaction data from other sources will be rejected.
  """

  # Initialize a transaction for this set of operations.
  transactionID = "T#{instant}"
  transactionAttributes =
    "time": instant

  # List of new datoms
  newDatoms = inputData.map (inputDatom) ->
    Immutable.fromJS [
      selectValueForTransactionOperation inputDatom[0]
      identifyInputDatom.call(this, inputDatom),
      inputDatom[2]
      inputDatom[3]
      instant
    ]

  facts.datoms = facts.datoms.pushAll(newDatoms)
  facts.datoms = facts.datoms.pushAll(Immutable.fromJS [
    [true, transactionID, "undecided", undefined, instant]
  ])

  # Compose the transaction report.
  report =
    "datoms": newDatoms
    "instant": instant
    "product": facts.database()
    "transaction": transactionID
  # Dispatch transaction event with the report.
  facts.dispatch "transaction", report
  # Return the transaction report.
  return report

identifyInputDatom = (inputDatom) ->
  id = inputDatom[1]
  if id is undefined
    @maxEntityId += 1 # Generate and return a new identifier.
  else
    id # Return existing identifier.

selectValueForTransactionOperation = (operation) ->
  if operation in [true, false, undefined]
    return operation
  else
    throw "Oops! '#{operation}' is not a recognized transaction operation. Try true, false or undefined."

identifiesTransaction = (datom) -> identifiesTransaction.pattern.test(datom[1])
identifiesTransaction.pattern = /T[0-9]+/
