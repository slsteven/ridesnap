ready = ->
  transform = {}
  start_x = 0

  handlePan = (ev) ->
    el = $(".actions[data-object='" + ev.target.dataset.object + "']")
    el.removeClass('accept').addClass('reject') if ev.deltaX < 0
    el.removeClass('reject').addClass('accept') if ev.deltaX > 0
    transform.translate = { x: start_x + ev.deltaX }
    updateElementTransform(ev.target.dataset.object)

  updateElementTransform = (obj) ->
    value = [
      'translate3d(' + transform.translate.x + 'px, 0px, 0)'
    ]
    value = value.join(" ")
    el = document.querySelector(".vehicle[data-object='" + obj + "']")
    el.style.webkitTransform = value
    el.style.mozTransform = value
    el.style.transform = value

  resetElement = ->
    transform = {
      translate: { x: start_x }
    }
    updateElementTransform()

  createHammer = (v) ->
    mc = new Hammer.Manager(v, {})
    mc.add new Hammer.Pan(
      direction: Hammer.DIRECTION_HORIZONTAL
      threshold: 20
    )
    mc.on 'panleft', handlePan
    mc.on 'panright', handlePan

  selector = '.market-place .vehicle'
  createHammer(v) for v in document.querySelectorAll(selector)

$(document).ready(ready)
$(document).on('page:load', ready)