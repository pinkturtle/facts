{List, Map, Stack} = Immutable = window?["Immutable"] or require("immutable")

class Facts
  window["Facts"] = this if window?
  module["exports"] = this if module?

  constructor: (options) ->
    if this instanceof Facts
      @initialize(options)
      return this
    else
      return new Facts options

  initialize: (options={}) ->
    @[key] = value for key, value of options when key isnt "datoms"
    if options.datoms
      if Stack.isStack(options.datoms)
        @datoms = options.datoms
      else
        @datoms = Stack options.datoms.map List
    if @cache isnt no
      @on "transaction", (report) ->
        @cache =
          "last transaction": report.transaction
          "instant of last transaction": report.instant
          "current database": report.product

  datoms: Stack()

  now: ->
    Facts.now()

  at: (max) ->
    if max is "now" then max = undefined
    Facts.database(this, {max, min:undefined})

  pull: (identifier, params={}) ->
    params.in = params.from if params.from?
    params.where = (id) -> id is identifier
    @query(params)[0]

  query: (params={}) ->
    params.in ?= [@at(params.at)]
    Facts.query(params)

  transact: (inputData, time) ->
    Facts.transact(this, inputData, time)

  true: (identifier, mapOfValues) ->
    @transact([true, identifier, attribute, value] for attribute, value of mapOfValues)

  false: (identifier, mapOfValues) ->
    @transact([false, identifier, attribute, value] for attribute, value of mapOfValues)

  undefined: (identifier, mapOfValues) ->
    @transact([undefined, identifier, attribute, value] for attribute, value of mapOfValues)

# Define aliases for at.
Facts::database = Facts::asOf = Facts::at

# Define aliases for pull.
Facts::get = Facts::entity = Facts::recall = Facts::retrieve = Facts::pull

# Define aliases for query.
Facts::pleaseAnswerMyQuestion = Facts::query

# Define aliases for transact.
Facts::commit = Facts::pushState = Facts::transact

# Define aliases for true, false and undefined.
Facts::divert = Facts::assert  = Facts::add       = Facts::advance = Facts::true
Facts::revert = Facts::retract = Facts::subtract  = Facts::reverse = Facts::false
Facts::unsure                  = Facts::uncertain = Facts::unknown = Facts::undefined

# Expose Immutable for window authors.
Facts.Immutable = Immutable

# Define construct alias for the apply method.
Facts.construct = Facts.apply

# -----------------------------------------------------------------------------
Facts.now = switch
  when window?.performance?.now instanceof Function
    -> performance.timing.navigationStart + performance.now()
  when global?.process?.hrtime instanceof Function
    programStartTime = Date.now() # there might be a more accurate source for this, open to suggestions...
    elapsedSinceProgramStart = ->
      time = global.process.hrtime()
      time[0] * 1e3 + time[1] / 1e6
    -> programStartTime + elapsedSinceProgramStart()
  else
    throw """
      Facts couldn’t locate a high-resolution time source in this environment.

      A high-resolution time source is required to ensure transactions don’t fall
      out of the pocket and ruin that fine-fine monotonic grooviness. Facts checked
      for window.performance.now and global.process.hrtime but neither of these
      functions was available.
    """

# -----------------------------------------------------------------------------
Facts.database = (facts, rangeOfTime) ->
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

# -----------------------------------------------------------------------------
Facts.query = (params) ->
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

# -----------------------------------------------------------------------------
Facts.transact = (facts, input, instant=facts.now()) ->
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

# -----------------------------------------------------------------------------
# Facts.Events was copied from Backbone.Events
# -----------------------------------------------------------------------------
# A module that can be mixed in to *any object* in order to provide it with
# a custom event channel. You may bind a callback to an event with `on` or
# remove with `off`; `trigger`-ing an event fires all callbacks in
# succession.
#
#     var object = {};
#     _.extend(object, Backbone.Events);
#     object.on('expand', function(){ alert('expanded'); });
#     object.trigger('expand');
#
Facts.Events = Events = {}
# Regular expression used to split event strings.
eventSplitter = /\s+/
# Iterates over the standard `event, callback` (as well as the fancy multiple
# space-separated events `"change blur", callback` and jQuery-style event
# maps `{event: callback}`).

eventsApi = (iteratee, events, name, callback, opts) ->
  i = 0
  names = undefined
  if name and typeof name == 'object'
    # Handle event maps.
    if callback != undefined and 'context' of opts and opts.context == undefined
      opts.context = callback
    names = Object.keys(name)
    while i < names.length
      events = eventsApi(iteratee, events, names[i], name[names[i]], opts)
      i++
  else if name and eventSplitter.test(name)
    # Handle space-separated event names by delegating them individually.
    names = name.split(eventSplitter)
    while i < names.length
      events = iteratee(events, names[i], callback, opts)
      i++
  else
    # Finally, standard events.
    events = iteratee(events, name, callback, opts)
  events

# Bind an event to a `callback` function. Passing `"all"` will bind
# the callback to all events fired.

Events.on = (name, callback, context) ->
  internalOn this, name, callback, context

# Guard the `listening` argument from the public API.

internalOn = (obj, name, callback, context, listening) ->
  obj._events = eventsApi(onApi, obj._events or {}, name, callback,
    context: context
    ctx: obj
    listening: listening)
  if listening
    listeners = obj._listeners or (obj._listeners = {})
    listeners[listening.id] = listening
  obj

# Inversion-of-control versions of `on`. Tell *this* object to listen to
# an event in another object... keeping track of what it's listening to
# for easier unbinding later.

Events.listenTo = (obj, name, callback) ->
  if !obj
    return this
  id = obj._listenId or (obj._listenId = _.uniqueId('l'))
  listeningTo = @_listeningTo or (@_listeningTo = {})
  listening = listeningTo[id]
  # This object is not listening to any other events on `obj` yet.
  # Setup the necessary references to track the listening callbacks.
  if !listening
    thisId = @_listenId or (@_listenId = _.uniqueId('l'))
    listening = listeningTo[id] =
      obj: obj
      objId: id
      id: thisId
      listeningTo: listeningTo
      count: 0
  # Bind callbacks on obj, and keep track of them on listening.
  internalOn obj, name, callback, this, listening
  this

# The reducing API that adds a callback to the `events` object.

onApi = (events, name, callback, options) ->
  if callback
    handlers = events[name] or (events[name] = [])
    context = options.context
    ctx = options.ctx
    listening = options.listening
    if listening
      listening.count++
    handlers.push
      callback: callback
      context: context
      ctx: context or ctx
      listening: listening
  events

# Remove one or many callbacks. If `context` is null, removes all
# callbacks with that function. If `callback` is null, removes all
# callbacks for the event. If `name` is null, removes all bound
# callbacks for all events.

Events.off = (name, callback, context) ->
  if !@_events
    return this
  @_events = eventsApi(offApi, @_events, name, callback,
    context: context
    listeners: @_listeners)
  this

# Tell this object to stop listening to either specific events ... or
# to every object it's currently listening to.

Events.stopListening = (obj, name, callback) ->
  listeningTo = @_listeningTo
  if !listeningTo
    return this
  ids = if obj then [ obj._listenId ] else Object.keys(listeningTo)
  i = 0
  while i < ids.length
    listening = listeningTo[ids[i]]
    # If listening doesn't exist, this object is not currently
    # listening to obj. Break out early.
    if !listening
      break
    listening.obj.off name, callback, this
    i++
  this

# The reducing API that removes a callback from the `events` object.

offApi = (events, name, callback, options) ->
  if !events
    return
  i = 0
  listening = undefined
  context = options.context
  listeners = options.listeners
  # Delete all events listeners and "drop" events.
  if !name and !callback and !context
    ids = Object.keys(listeners)
    while i < ids.length
      listening = listeners[ids[i]]
      delete listeners[listening.id]
      delete listening.listeningTo[listening.objId]
      i++
    return
  names = if name then [ name ] else Object.keys(events)
  while i < names.length
    name = names[i]
    handlers = events[name]
    # Bail out if there are no events stored.
    if !handlers
      break
    # Replace events if there are any remaining.  Otherwise, clean up.
    remaining = []
    j = 0
    while j < handlers.length
      handler = handlers[j]
      if callback and callback != handler.callback and callback != handler.callback._callback or context and context != handler.context
        remaining.push handler
      else
        listening = handler.listening
        if listening and --listening.count == 0
          delete listeners[listening.id]
          delete listening.listeningTo[listening.objId]
      j++
    # Update tail event if the list has any events.  Otherwise, clean up.
    if remaining.length
      events[name] = remaining
    else
      delete events[name]
    i++
  events

# Bind an event to only be triggered a single time. After the first time
# the callback is invoked, its listener will be removed. If multiple events
# are passed in using the space-separated syntax, the handler will fire
# once for each event, not once for a combination of all events.

Events.once = (name, callback, context) ->
  # Map the event into a `{event: once}` object.
  events = eventsApi(onceMap, {}, name, callback, Function.bind(@off, this))
  if typeof name == 'string' and context == null
    callback = undefined
  @on events, callback, context

# Inversion-of-control versions of `once`.

Events.listenToOnce = (obj, name, callback) ->
  # Map the event into a `{event: once}` object.
  events = eventsApi(onceMap, {}, name, callback, Function.bind(@stopListening, this, obj))
  @listenTo obj, events

# Reduces the event callbacks into a map of `{event: onceWrapper}`.
# `offer` unbinds the `onceWrapper` after it has been called.

onceMap = (map, name, callback, offer) ->
  if callback
    once = map[name] = _.once(->
      offer name, once
      callback.apply this, arguments
      return
    )
    once._callback = callback
  map

# Trigger one or many events, firing all bound callbacks. Callbacks are
# passed the same arguments as `trigger` is, apart from the event name
# (unless you're listening on `"all"`, which will cause your callback to
# receive the true name of the event as the first argument).

Events.trigger = (name) ->
  if !@_events
    return this
  length = Math.max(0, arguments.length - 1)
  args = Array(length)
  i = 0
  while i < length
    args[i] = arguments[i + 1]
    i++
  eventsApi triggerApi, @_events, name, undefined, args
  this

# Handles triggering the appropriate event callbacks.

triggerApi = (objEvents, name, callback, args) ->
  if objEvents
    events = objEvents[name]
    allEvents = objEvents.all
    if events and allEvents
      allEvents = allEvents.slice()
    if events
      triggerEvents events, args
    if allEvents
      triggerEvents allEvents, [ name ].concat(args)
  objEvents

# A difficult-to-believe, but optimized internal dispatch function for
# triggering events. Tries to keep the usual cases speedy (most internal
# Backbone events have 3 arguments).

triggerEvents = (events, args) ->
  ev = undefined
  i = -1
  l = events.length
  a1 = args[0]
  a2 = args[1]
  a3 = args[2]
  switch args.length
    when 0
      while ++i < l
        (ev = events[i]).callback.call ev.ctx
      return
    when 1
      while ++i < l
        (ev = events[i]).callback.call ev.ctx, a1
      return
    when 2
      while ++i < l
        (ev = events[i]).callback.call ev.ctx, a1, a2
      return
    when 3
      while ++i < l
        (ev = events[i]).callback.call ev.ctx, a1, a2, a3
      return
    else
      while ++i < l
        (ev = events[i]).callback.apply ev.ctx, args
      return
  return

# Extend Facts prototype with methods from Events.
Facts::[key] = value for key, value of Events
Facts::dispatch = Facts::trigger
