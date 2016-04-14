document.on "DOMContentLoaded", ->
  document.query("img[width][height]").forEach (img) ->
    canvas = document.createElement("canvas")
    canvas.width = img.getAttribute("width")
    canvas.height = img.getAttribute("height")
    img.removeAttribute("width")
    img.removeAttribute("height")
    img.src = canvas.toDataURL()
  document.query("video[width][height]:not([poster])").forEach (video) ->
    canvas = document.createElement("canvas")
    canvas.width = video.getAttribute("width")
    canvas.height = video.getAttribute("height")
    video.removeAttribute("width")
    video.removeAttribute("height")
    video.poster = canvas.toDataURL()

window.addEventListener "load", ->
  Function.delay 1.second(), ->
    document.query("img[data-src]").forEach (img) ->
      getImage img.getAttribute("data-src"), (imageURL) ->
        img.src = img.getAttribute("data-src")
        img.classList.add("loaded")
    document.query("video[data-poster]").forEach (video) ->
      getImage video.getAttribute("data-poster"), (imageURL) ->
        video.poster = imageURL
        video.classList.add("loaded")

getImage = (src, callback) ->
  img = document.createElement("img")
  img.onload = -> callback(src)
  img.src = src
