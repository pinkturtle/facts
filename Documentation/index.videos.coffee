# Hyperlink to play a video

document.on "mouseover", "a.play.video[href]", (event, hyperlink) ->
  id = hyperlink.getAttribute("href").split("#").pop()
  [address, id, query] = hyperlink.getAttribute("href").split("#")
  instant = Number(query.substr(2, 2)).minutes() + Number(query.substr(5, 7)).seconds()
  video = document.getElementById(id)
  if video.readyState is 0
    video.load()
  if video.paused is true
    video.currentTime = Math.round(instant / 1.second())

document.on "click", "a.play.video[href]", (event, hyperlink) ->
  event.preventDefault()
  [address, id, query] = hyperlink.getAttribute("href").split("#")
  instant = Number(query.substr(2, 2)).minutes() + Number(query.substr(5, 7)).seconds()
  seconds = Number(query.substr(5, 7)).seconds()
  video = document.getElementById(id)
  video.currentTime = Math.round(instant / 1.second())
  video.play()

# Videos with Audio
document.on "mouseover", "video:not(.silent)", (event, video) ->
  if video.readyState is 0 then video.load()

document.on "mousedown", "video:not(.silent)", (event, video) ->
  # event.preventDefault()
  if video.paused then video.play() else video.pause()

# Silent Videos
document.on "mouseover", "video.silent", (event, video) ->
  if video.readyState is 4
    video.play()
  else
    video.addEventListener "canplay", playWhenReady = (event) ->
      video.removeEventListener("canplay", playWhenReady)
      video.play()
    if video.readyState is 0
      video.load()

document.on "mouseout", "video.silent", (event, video) ->
  video.pause()
