if window?
  exports.tape = require("./window.test.harness")
  exports.Facts = window.Facts
else
  exports.tape = require("tape")
  exports.Facts = require("../facts.core")

exports.Immutable = exports.Facts.Immutable
