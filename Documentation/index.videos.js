// Generated by CoffeeScript 1.8.0
(function() {
  document.on("mouseover", "a.play.video[href]", function(event, hyperlink) {
    var address, id, instant, query, video, _ref;
    id = hyperlink.getAttribute("href").split("#").pop();
    _ref = hyperlink.getAttribute("href").split("#"), address = _ref[0], id = _ref[1], query = _ref[2];
    instant = Number(query.substr(2, 2)).minutes() + Number(query.substr(5, 7)).seconds();
    video = document.getElementById(id);
    if (video.readyState === 0) {
      video.load();
    }
    if (video.paused === true) {
      return video.currentTime = Math.round(instant / 1..second());
    }
  });

  document.on("click", "a.play.video[href]", function(event, hyperlink) {
    var address, id, instant, query, seconds, video, _ref;
    event.preventDefault();
    _ref = hyperlink.getAttribute("href").split("#"), address = _ref[0], id = _ref[1], query = _ref[2];
    instant = Number(query.substr(2, 2)).minutes() + Number(query.substr(5, 7)).seconds();
    seconds = Number(query.substr(5, 7)).seconds();
    video = document.getElementById(id);
    video.currentTime = Math.round(instant / 1..second());
    return video.play();
  });

  document.on("mouseover", "video:not(.silent)", function(event, video) {
    if (video.readyState === 0) {
      return video.load();
    }
  });

  document.on("mousedown", "video:not(.silent)", function(event, video) {
    if (video.paused) {
      return video.play();
    } else {
      return video.pause();
    }
  });

  document.on("mouseover", "video.silent", function(event, video) {
    var playWhenReady;
    if (video.readyState === 4) {
      return video.play();
    } else {
      video.addEventListener("canplay", playWhenReady = function(event) {
        video.removeEventListener("canplay", playWhenReady);
        return video.play();
      });
      if (video.readyState === 0) {
        return video.load();
      }
    }
  });

  document.on("mouseout", "video.silent", function(event, video) {
    return video.pause();
  });

}).call(this);
