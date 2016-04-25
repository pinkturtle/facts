Immutable = require "immutable"

module.exports = (facts, inputData, instant=facts.now()) ->
  if typeof inputData?.map isnt "function"
    throw "Facts.transact can’t create a transaction without a list of input."
  if inputData.length is 0
    throw "Facts.transact can’t create a transaction with an empty list of input data."

  # Initialize a transaction for this set of operations.
  transactionID = "T#{instant}"
  transactionAttributes =
    "time": instant

  # Select the database to operate on.
  databaseBeforeTransaction = selectDatabaseForTransaction.call(facts)

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
    [true, transactionID, "time", instant, instant]
  ])

  # Add database to history.
  facts.history = facts.history.push(databaseAfterTransaction = facts.at())
  facts.historyIndex = facts.history.count() - 1
  # Compose the transaction report.
  report =
    "transaction": transactionID
    "db before": databaseBeforeTransaction
    "db after": databaseAfterTransaction
    "data": newDatoms
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

selectDatabaseForTransaction = ->
  if @history.last().hashCode() isnt @history.get(@historyIndex).hashCode()
    console.info "Pushing Old Database to end"
    @history = @history.push @history.get(@historyIndex)
    @historyIndex = history.count() - 1
    return @history.last()
  else
    return @history.last()

selectValueForTransactionOperation = (operation) ->
  if operation in [true, false, undefined]
    return operation
  else
    throw "Oops! '#{operation}' is not a recognized transaction operation. Try true, false or undefined."
