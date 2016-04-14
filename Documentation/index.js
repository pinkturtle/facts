// Generated by CoffeeScript 1.8.0
(function() {
  window.addEventListener("load", function() {
    return window.requestAnimationFrame(function() {
      return document.querySelector("body").classList.add("initialized");
    });
  });

  document.on("mouseover", "div.console:not(.invoked)", function(event, div) {
    var stringElement, transactionID, _i, _len, _ref;
    transactionID = "T" + (Date.now());
    _ref = div.querySelectorAll("pre.output .hljs-string");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      stringElement = _ref[_i];
      if (stringElement.innerText === '"TNOW"') {
        stringElement.innerText = '"' + transactionID + '"';
      }
    }
    return Function.delay(33, function() {
      return window.requestAnimationFrame(function() {
        div.classList.add("invoked");
        return window.requestAnimationFrame(function() {
          return div.classList.add("returned");
        });
      });
    });
  });

}).call(this);