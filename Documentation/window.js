// Generated by CoffeeScript 1.8.0
(function() {
  if (location.hostname === "pinkturtle.github.io" && location.protocol !== "https:") {
    window.location = location.toString().replace("http:", "https:");
  }

  Number.prototype.millisecond = Number.prototype.milliseconds = function() {
    return this.valueOf();
  };

  Number.prototype.second = Number.prototype.seconds = function() {
    return this.milliseconds() * 1000;
  };

  Number.prototype.minute = Number.prototype.minutes = function() {
    return this.seconds() * 60;
  };

  Number.prototype.hour = Number.prototype.hours = function() {
    return this.minutes() * 60;
  };

  Function.delay = function(amount, procedure) {
    return setTimeout(procedure, amount);
  };

  Function.defer = function(procedure) {
    return setTimeout(procedure, 1);
  };

  Function.prototype.delay = function(amount) {
    return Function.delay(amount, this);
  };

  Function.prototype.defer = function() {
    return Function.defer(this);
  };

  document.initialized = Date.now();

  document.pull = document.querySelector;

  document.query = function(selector) {
    return Array.from(document.querySelectorAll(selector));
  };

  document.on = function(eventname, selector, procedure) {
    var wrapped;
    if (selector instanceof Function) {
      procedure = selector;
      selector = void 0;
    }
    if (selector) {
      wrapped = function(event) {
        var element;
        if (element = event.target.closest(selector)) {
          return procedure(event, element);
        }
      };
    } else {
      wrapped = procedure;
    }
    return document.addEventListener(eventname, wrapped);
  };

  document.on("DOMContentLoaded", function() {
    return console.info("document object model is ready", Date.now() - document.initialized);
  });

  window.addEventListener("load", function() {
    return console.info("window has loaded", Date.now() - document.initialized);
  });

  window.pointer = {
    x: 0,
    y: 0
  };

  document.on("DOMContentLoaded", function() {
    return window.pointer = {
      x: 0,
      y: 0
    };
  });

  document.on("mousemove", function(event) {
    return window.pointer = {
      x: event.clientX,
      y: event.clientY
    };
  });

}).call(this);