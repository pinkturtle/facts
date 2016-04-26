if window?
  exports.tape = require("./window.test.harness")
  exports.Facts = window.Facts
else
  exports.tape = require("tape")
  exports.Facts = require("..")

exports.Immutable = exports.Facts.Immutable

exports.tape.Test.prototype.exception = (string, procedure) ->
  this.throws procedure, string
