ready = ->
  transform = {}

  handlePan = (ev) ->
    console.log ev
    el = $(".actions[data-object='" + ev.target.dataset.object + "']")
    el.removeClass('accept').addClass('reject') if ev.deltaX < 0
    el.removeClass('reject').addClass('accept') if ev.deltaX > 0
    transform.translate = { x: ev.deltaX }
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

  resetElement = (ev) ->
    if ev.isFinal
      transform.translate = { x: 0 }
      updateElementTransform(ev.target.dataset.object)

  createHammer = (v) ->
    mc = new Hammer.Manager(v, {})
    mc.add new Hammer.Pan(
      direction: Hammer.DIRECTION_HORIZONTAL
      threshold: 0
    )
    mc.on 'panleft', handlePan
    mc.on 'panright', handlePan
    mc.on 'panend', resetElement

  selector = '.market-place .vehicle'
  createHammer(v) for v in document.querySelectorAll(selector)

$(document).ready(ready)
$(document).on('page:load', ready)