# This script automatically creates transparent placeholder images based on the width and height
# attributes of <img> and <video> tags in your HTML document. These placeholders establish stable
# visual media element aspect ratios while the window is loading. After the window load event, this
# script replaces the placeholders with images defined by img[data-src] and video[data-poster].
#
# Instructions:
#
# Include the width.height.js script anywhere on your page. Then re-write your <img> and <video>
# tags so that they specify image sources with data-src or data-poster attributes.
#
# Examples:
#
# Image:   <img src="nicola.jpg" width="200" height="60">
# Becomes: <img data-src="nicola.jpg" width="200" height="60">
#
# Video:   <video poster="sienna.jpg" width="200" height="60" src="sienna.mov">
# Becomes: <video data-poster="sienna.jpg" width="200" height="60" src="sienna.mov">


# Construct appropriately sized placeholder images for <img> and <video> tags when the DOM is ready.
# All <img> and <video> tags with width and height attributes are processed unless they already have
# their img[src] or video[poster] attribute defined.
document.addEventListener "DOMContentLoaded", ->
  query("img[width][height]:not([src])").forEach (img) ->
    constructPlaceholderImage img, "src"
  query("video[width][height]:not([poster])").forEach (video) ->
    constructPlaceholderImage video, "poster"


# Load images from img[data-src] and video[data-poster] attributes after the window has loaded all
# the initially required resources. The img[src] and video[poster] attributes will be updated after
# their image data has loaded.
window.addEventListener "load", ->
  query("img[data-src]").forEach (img) ->
    replacePlaceholderWhenSourceHasLoaded img, "data-src", "src"
  query("video[data-poster]").forEach (video) ->
    replacePlaceholderWhenSourceHasLoaded video, "data-poster", "poster"


# -------------------------------------------------------------------------------------------------

constructPlaceholderImage = (element, attribute) ->
  canvas = document.createElement("canvas")
  canvas.width = element.getAttribute("width")
  canvas.height = element.getAttribute("height")
  element.removeAttribute("width")
  element.removeAttribute("height")
  element[attribute] = canvas.toDataURL()

replacePlaceholderWhenSourceHasLoaded = (element, source, destination) ->
  loadImage element.getAttribute(source), (address) ->
    element[destination] = address
    element.classList.add("loaded")

loadImage = (address, callback) ->
  img = document.createElement("img")
  img.onload = -> callback(address)
  img.src = address

query = (selector) ->
  Array.from(document.querySelectorAll(selector))
