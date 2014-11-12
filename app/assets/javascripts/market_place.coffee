ready = ->
  transform = {}
  start_x = 0

  handleSwipeLeft = (ev) ->
    console.log(ev)

  handleSwipeRight = (ev) ->
    console.log(ev)

  updateElementTransform = (el) ->
    value = [
      'translate3d(' + transform.translate.x + 'px, 0px, 0)'
    ]
    value = value.join(" ")
    el = document.querySelector(".vehicle[data-object='" + el + "']")
    el.style.webkitTransform = value
    el.style.mozTransform = value
    el.style.transform = value

  resetElement = ->
    transform = {
      translate: { x: start_x }
    }
    updateElementTransform()

  onPan = (ev) ->
    console.log(ev)
    # ev.target.dataset.object
    transform.translate = {
      x: start_x + ev.deltaX
    }
    updateElementTransform(ev.target.dataset.object)

  createHammer = (v) ->
    mc = new Hammer.Manager(v, {})
    mc.add new Hammer.Pan(
      direction: Hammer.DIRECTION_HORIZONTAL
      threshold: 20
    )
    mc.on 'panleft', onPan
    mc.on 'panright', onPan

  selector = '.market-place .vehicle'
  createHammer(v) for v in document.querySelectorAll(selector)

$(document).ready(ready)
$(document).on('page:load', ready)