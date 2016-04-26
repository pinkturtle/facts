// https://pinkturtle.github.io/facts version 0.0.0
// Requires https://facebook.github.io/immutable-js
// ••••••••••••••••••••••••••••••••••••••••••••••••
// Facts.js (Public Domain)
// Generated by CoffeeScript 1.10.0
(function() {
  var Datom, Events, Facts, Immutable, List, Map, Set, Stack, dispatch, elapsedSinceProgramStart, eventSplitter, eventsApi, identifiesTransaction, internalOn, isTransaction, isUnrecognizedOperation, key, match, offApi, onApi, onceMap, programStartTime, recognizedOperations, ref, takeSampleOf, toIdentifiedEntities, toTruth, triggerApi, triggerEvents, validate, value,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ref = Immutable = (typeof window !== "undefined" && window !== null ? window["Immutable"] : void 0) || require("immutable"), List = ref.List, Map = ref.Map, Set = ref.Set, Stack = ref.Stack;

  Facts = (function() {
    if (typeof window !== "undefined" && window !== null) {
      window["Facts"] = Facts;
    }

    if (typeof module !== "undefined" && module !== null) {
      module["exports"] = Facts;
    }

    function Facts(options) {
      if (this instanceof Facts) {
        this.initialize(options);
        return this;
      } else {
        return new Facts(options);
      }
    }

    Facts.prototype.initialize = function(options) {
      var key, value;
      if (options == null) {
        options = {};
      }
      for (key in options) {
        value = options[key];
        if (key !== "datoms") {
          this[key] = value;
        }
      }
      if (options.datoms) {
        if (Stack.isStack(options.datoms)) {
          this.datoms = options.datoms;
        } else {
          this.datoms = Stack(options.datoms.map(List));
        }
      }
      if (this.cache !== false) {
        return this.on("transaction", function(report) {
          return this.cache = {
            "last transaction": report.transaction,
            "instant of last transaction": report.instant,
            "current database": report.product
          };
        });
      }
    };

    Facts.prototype.datoms = Stack();

    Facts.prototype.now = function() {
      return Facts.now();
    };

    Facts.prototype.at = function(max) {
      if (max === "now") {
        max = void 0;
      }
      return Facts.database(this, {
        max: max,
        min: void 0
      });
    };

    Facts.prototype.pull = function(identifier, params) {
      if (params == null) {
        params = {};
      }
      if (params.from != null) {
        params["in"] = params.from;
      }
      params.where = function(id) {
        return id === identifier;
      };
      return this.query(params)[0];
    };

    Facts.prototype.query = function(params) {
      if (params == null) {
        params = {};
      }
      if (params["in"] == null) {
        params["in"] = [this.at(params.at)];
      }
      return Facts.query(params);
    };

    Facts.prototype.transact = function(inputData, time) {
      return Facts.transact(this, inputData, time);
    };

    Facts.prototype["true"] = function(identifier, mapOfValues) {
      var attribute, value;
      return this.transact((function() {
        var results;
        results = [];
        for (attribute in mapOfValues) {
          value = mapOfValues[attribute];
          results.push([true, identifier, attribute, value]);
        }
        return results;
      })());
    };

    Facts.prototype["false"] = function(identifier, mapOfValues) {
      var attribute, value;
      return this.transact((function() {
        var results;
        results = [];
        for (attribute in mapOfValues) {
          value = mapOfValues[attribute];
          results.push([false, identifier, attribute, value]);
        }
        return results;
      })());
    };

    Facts.prototype.undefined = function(identifier, mapOfValues) {
      var attribute, value;
      return this.transact((function() {
        var results;
        results = [];
        for (attribute in mapOfValues) {
          value = mapOfValues[attribute];
          results.push([void 0, identifier, attribute, value]);
        }
        return results;
      })());
    };

    return Facts;

  })();

  Facts.prototype.database = Facts.prototype.asOf = Facts.prototype.at;

  Facts.prototype.get = Facts.prototype.entity = Facts.prototype.recall = Facts.prototype.retrieve = Facts.prototype.pull;

  Facts.prototype.pleaseAnswerMyQuestion = Facts.prototype.query;

  Facts.prototype.commit = Facts.prototype.pushState = Facts.prototype.transact;

  Facts.prototype.divert = Facts.prototype.assert = Facts.prototype.add = Facts.prototype.advance = Facts.prototype["true"];

  Facts.prototype.revert = Facts.prototype.retract = Facts.prototype.subtract = Facts.prototype.reverse = Facts.prototype["false"];

  Facts.prototype.unsure = Facts.prototype.uncertain = Facts.prototype.unknown = Facts.prototype.undefined;

  Facts.Immutable = Immutable;

  Facts.construct = Facts.apply;

  Facts.now = (function() {
    var ref1, ref2;
    switch (false) {
      case !((typeof window !== "undefined" && window !== null ? (ref1 = window.performance) != null ? ref1.now : void 0 : void 0) instanceof Function):
        return function() {
          return performance.timing.navigationStart + performance.now();
        };
      case !((typeof global !== "undefined" && global !== null ? (ref2 = global.process) != null ? ref2.hrtime : void 0 : void 0) instanceof Function):
        programStartTime = Date.now();
        elapsedSinceProgramStart = function() {
          var time;
          time = global.process.hrtime();
          return time[0] * 1e3 + time[1] / 1e6;
        };
        return function() {
          return programStartTime + elapsedSinceProgramStart();
        };
      default:
        throw "Facts couldn’t locate a high-resolution time source in this environment.\n\nA high-resolution time source is required to ensure transactions don’t fall\nout of the pocket and ruin that fine-fine monotonic grooviness. Facts checked\nfor window.performance.now and global.process.hrtime but neither of these\nfunctions was available.";
    }
  })();

  Facts.database = function(facts, rangeOfTime) {
    var database, reduction, sample;
    sample = takeSampleOf(facts.datoms, rangeOfTime);
    reduction = sample.reduce(toTruth(), Immutable.fromJS({
      datoms: [],
      entities: {}
    }));
    database = Immutable.Stack(reduction.get("datoms"));
    database.entities = reduction.get("entities");
    return database;
  };

  takeSampleOf = function(datoms, range) {
    var ref1;
    switch (false) {
      case (range.min !== (ref1 = range.max) || ref1 !== void 0):
        return datoms;
      case !(range.max !== void 0 && range.min === void 0):
        return datoms.skipUntil(function(datom) {
          return datom.get(4) <= range.max;
        });
      case !(range.max === void 0 && range.min !== void 0):
        return datoms.takeWhile(function(datom) {
          return datom.get(4) >= range.min;
        });
      default:
        return datoms.skipUntil(function(datom) {
          return datom.get(4) <= range.max;
        }).takeWhile(function(datom) {
          return datom.get(4) >= range.min;
        });
    }
  };

  toTruth = function() {
    var untrue, untruthiness;
    untrue = [false, void 0];
    untruthiness = [];
    return function(memo, datom, key) {
      var ref1;
      if (isTransaction(datom)) {
        return memo;
      }
      if ((ref1 = datom.get(0), indexOf.call(untrue, ref1) >= 0) && untruthiness.push(datom)) {
        return memo;
      }
      if (untruthiness.some(function(untrue) {
        return match(untrue, datom) && (untrue.get(4) > datom.get(4));
      })) {
        return memo;
      }
      if (memo.hasIn(["entities", datom.get(1), datom.get(2)])) {
        return memo;
      }
      return memo.setIn(["datoms"], memo.get("datoms").push(datom)).setIn(["entities", datom.get(1), datom.get(2)], datom.get(3));
    };
  };

  isTransaction = function(datom) {
    return isTransaction.pattern.test(datom.get(1));
  };

  isTransaction.pattern = /T[0-9]+/;

  match = function(pattern, datom) {
    return (pattern.get(1) === datom.get(1)) && (pattern.get(2) === datom.get(2)) && (pattern.get(3) === datom.get(3));
  };

  Facts.query = function(params) {
    var database, entities, filtered, identifiers;
    database = params["in"][0];
    if (params.where) {
      filtered = database.filter(function(datom) {
        return params.where(datom.get(1), datom.get(2), datom.get(3), datom.get(4));
      });
    } else {
      filtered = database;
    }
    identifiers = Set(filtered.map(function(datom) {
      return datom.get(1);
    }));
    entities = database.reduce(toIdentifiedEntities, {
      identifiers: identifiers,
      entities: Map()
    }).entities;
    switch (params.out || Array) {
      case Array:
        return entities.toList().toJS();
      case List:
        return entities.toList();
      case Map:
        return entities;
      case Object:
        return entities.toJS();
      default:
        throw "Oops! " + (JSON.stringify(params.out)) + " is not a recognized query output format.";
    }
  };

  toIdentifiedEntities = function(reduction, datom) {
    var entities, identifier, identifiers;
    entities = reduction.entities, identifiers = reduction.identifiers;
    if (identifiers.contains(identifier = datom.get(1))) {
      entities = entities.setIn([datom.get(1), "id"], datom.get(1));
      entities = entities.setIn([datom.get(1), datom.get(2)], datom.get(3));
      return {
        identifiers: identifiers,
        entities: entities
      };
    } else {
      return reduction;
    }
  };

  Facts.transact = function(facts, input, instant) {
    var novelty, report, transactionDatom;
    if (instant == null) {
      instant = facts.now();
    }
    novelty = Immutable.List(validate(input)).map(function(values) {
      return Datom.fromInput(values, instant);
    });
    transactionDatom = Datom(true, "T" + instant, "undecided", void 0, instant);
    facts.datoms = facts.datoms.unshiftAll(novelty).unshift(transactionDatom);
    return dispatch(facts, "transaction", report = {
      datoms: novelty,
      instant: instant,
      product: facts.database(),
      transaction: "T" + instant
    });
  };

  Datom = function(fact, identifier, attribute, value, instant) {
    return Immutable.List.of(fact, identifier, attribute, value, instant);
  };

  Datom.fromInput = function(values, instant) {
    return Datom(values[0], values[1], values[2], Immutable.fromJS(values[3]), instant);
  };

  dispatch = function(facts, event, report) {
    setTimeout((function() {
      return facts.dispatch("transaction", report);
    }), 1);
    return report;
  };

  validate = function(input) {
    var someTransactions, transactions, unrecognizedOperations;
    if (typeof (input != null ? input.map : void 0) !== "function") {
      throw "Facts.transact can’t create a transaction without a list of input.";
    }
    if (input.length === 0) {
      throw "Facts.transact can’t create a transaction with an empty list of input data.";
    }
    unrecognizedOperations = input.filter(isUnrecognizedOperation).map(function(data) {
      return data[0];
    });
    if (unrecognizedOperations.length !== 0) {
      throw "Oops! '" + unrecognizedOperations.first + "' is not a recognized transaction operation. Try true, false or undefined.";
    }
    transactions = input.filter(identifiesTransaction).map(function(data) {
      return data[1];
    });
    if (transactions.length !== 0) {
      someTransactions = transactions.length === 1 ? "another transaction" : transactions.length + " other transactions";
      throw "Transaction was aborted because its input contained data that identified " + someTransactions + ": " + (transactions.join(" ")) + "\n\nTransactions may not be explicitly advanced, reversed or unknown because Facts relies on\nthem as its implicit record of what happened when. Facts.transact is the only function\npermitted to construct transactions. Transaction data from other sources will be rejected.";
    }
    return input;
  };

  identifiesTransaction = function(datom) {
    return identifiesTransaction.pattern.test(datom[1]);
  };

  identifiesTransaction.pattern = /T[0-9]+/;

  recognizedOperations = [true, false, void 0];

  isUnrecognizedOperation = function(datom) {
    var ref1;
    return (ref1 = datom[0], indexOf.call(recognizedOperations, ref1) >= 0) === false;
  };

  Facts.Events = Events = {};

  eventSplitter = /\s+/;

  eventsApi = function(iteratee, events, name, callback, opts) {
    var i, names;
    i = 0;
    names = void 0;
    if (name && typeof name === 'object') {
      if (callback !== void 0 && 'context' in opts && opts.context === void 0) {
        opts.context = callback;
      }
      names = Object.keys(name);
      while (i < names.length) {
        events = eventsApi(iteratee, events, names[i], name[names[i]], opts);
        i++;
      }
    } else if (name && eventSplitter.test(name)) {
      names = name.split(eventSplitter);
      while (i < names.length) {
        events = iteratee(events, names[i], callback, opts);
        i++;
      }
    } else {
      events = iteratee(events, name, callback, opts);
    }
    return events;
  };

  Events.on = function(name, callback, context) {
    return internalOn(this, name, callback, context);
  };

  internalOn = function(obj, name, callback, context, listening) {
    var listeners;
    obj._events = eventsApi(onApi, obj._events || {}, name, callback, {
      context: context,
      ctx: obj,
      listening: listening
    });
    if (listening) {
      listeners = obj._listeners || (obj._listeners = {});
      listeners[listening.id] = listening;
    }
    return obj;
  };

  Events.listenTo = function(obj, name, callback) {
    var id, listening, listeningTo, thisId;
    if (!obj) {
      return this;
    }
    id = obj._listenId || (obj._listenId = _.uniqueId('l'));
    listeningTo = this._listeningTo || (this._listeningTo = {});
    listening = listeningTo[id];
    if (!listening) {
      thisId = this._listenId || (this._listenId = _.uniqueId('l'));
      listening = listeningTo[id] = {
        obj: obj,
        objId: id,
        id: thisId,
        listeningTo: listeningTo,
        count: 0
      };
    }
    internalOn(obj, name, callback, this, listening);
    return this;
  };

  onApi = function(events, name, callback, options) {
    var context, ctx, handlers, listening;
    if (callback) {
      handlers = events[name] || (events[name] = []);
      context = options.context;
      ctx = options.ctx;
      listening = options.listening;
      if (listening) {
        listening.count++;
      }
      handlers.push({
        callback: callback,
        context: context,
        ctx: context || ctx,
        listening: listening
      });
    }
    return events;
  };

  Events.off = function(name, callback, context) {
    if (!this._events) {
      return this;
    }
    this._events = eventsApi(offApi, this._events, name, callback, {
      context: context,
      listeners: this._listeners
    });
    return this;
  };

  Events.stopListening = function(obj, name, callback) {
    var i, ids, listening, listeningTo;
    listeningTo = this._listeningTo;
    if (!listeningTo) {
      return this;
    }
    ids = obj ? [obj._listenId] : Object.keys(listeningTo);
    i = 0;
    while (i < ids.length) {
      listening = listeningTo[ids[i]];
      if (!listening) {
        break;
      }
      listening.obj.off(name, callback, this);
      i++;
    }
    return this;
  };

  offApi = function(events, name, callback, options) {
    var context, handler, handlers, i, ids, j, listeners, listening, names, remaining;
    if (!events) {
      return;
    }
    i = 0;
    listening = void 0;
    context = options.context;
    listeners = options.listeners;
    if (!name && !callback && !context) {
      ids = Object.keys(listeners);
      while (i < ids.length) {
        listening = listeners[ids[i]];
        delete listeners[listening.id];
        delete listening.listeningTo[listening.objId];
        i++;
      }
      return;
    }
    names = name ? [name] : Object.keys(events);
    while (i < names.length) {
      name = names[i];
      handlers = events[name];
      if (!handlers) {
        break;
      }
      remaining = [];
      j = 0;
      while (j < handlers.length) {
        handler = handlers[j];
        if (callback && callback !== handler.callback && callback !== handler.callback._callback || context && context !== handler.context) {
          remaining.push(handler);
        } else {
          listening = handler.listening;
          if (listening && --listening.count === 0) {
            delete listeners[listening.id];
            delete listening.listeningTo[listening.objId];
          }
        }
        j++;
      }
      if (remaining.length) {
        events[name] = remaining;
      } else {
        delete events[name];
      }
      i++;
    }
    return events;
  };

  Events.once = function(name, callback, context) {
    var events;
    events = eventsApi(onceMap, {}, name, callback, Function.bind(this.off, this));
    if (typeof name === 'string' && context === null) {
      callback = void 0;
    }
    return this.on(events, callback, context);
  };

  Events.listenToOnce = function(obj, name, callback) {
    var events;
    events = eventsApi(onceMap, {}, name, callback, Function.bind(this.stopListening, this, obj));
    return this.listenTo(obj, events);
  };

  onceMap = function(map, name, callback, offer) {
    var once;
    if (callback) {
      once = map[name] = _.once(function() {
        offer(name, once);
        callback.apply(this, arguments);
      });
      once._callback = callback;
    }
    return map;
  };

  Events.trigger = function(name) {
    var args, i, length;
    if (!this._events) {
      return this;
    }
    length = Math.max(0, arguments.length - 1);
    args = Array(length);
    i = 0;
    while (i < length) {
      args[i] = arguments[i + 1];
      i++;
    }
    eventsApi(triggerApi, this._events, name, void 0, args);
    return this;
  };

  triggerApi = function(objEvents, name, callback, args) {
    var allEvents, events;
    if (objEvents) {
      events = objEvents[name];
      allEvents = objEvents.all;
      if (events && allEvents) {
        allEvents = allEvents.slice();
      }
      if (events) {
        triggerEvents(events, args);
      }
      if (allEvents) {
        triggerEvents(allEvents, [name].concat(args));
      }
    }
    return objEvents;
  };

  triggerEvents = function(events, args) {
    var a1, a2, a3, ev, i, l;
    ev = void 0;
    i = -1;
    l = events.length;
    a1 = args[0];
    a2 = args[1];
    a3 = args[2];
    switch (args.length) {
      case 0:
        while (++i < l) {
          (ev = events[i]).callback.call(ev.ctx);
        }
        return;
      case 1:
        while (++i < l) {
          (ev = events[i]).callback.call(ev.ctx, a1);
        }
        return;
      case 2:
        while (++i < l) {
          (ev = events[i]).callback.call(ev.ctx, a1, a2);
        }
        return;
      case 3:
        while (++i < l) {
          (ev = events[i]).callback.call(ev.ctx, a1, a2, a3);
        }
        return;
      default:
        while (++i < l) {
          (ev = events[i]).callback.apply(ev.ctx, args);
        }
        return;
    }
  };

  for (key in Events) {
    value = Events[key];
    Facts.prototype[key] = value;
  }

  Facts.prototype.dispatch = Facts.prototype.trigger;

}).call(this);
