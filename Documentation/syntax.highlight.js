// Generated by CoffeeScript 1.8.0
(function() {
  document.on("DOMContentLoaded", function(event) {
    return Array.from(document.querySelectorAll("pre.ecmascript,code")).forEach(function(element) {
      element.classList.add("js");
      return hljs.highlightBlock(element);
    });
  });

}).call(this);