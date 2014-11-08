ready = ->
  handleSwipeLeft = (ev) ->
    console.log(ev)

  handleSwipeRight = (ev) ->
    console.log(ev)

  onPan = (ev) ->
    console.log(ev)

  createHammer = (v) ->
    mc = new Hammer.Manager(v, {})
    mc.add new Hammer.Pan(
      direction: Hammer.DIRECTION_HORIZONTAL
      threshold: 20
    )
    mc.on 'panleft', onPan
    mc.on 'panright', onPan

  createHammer for v in document.querySelectorAll('.market-place .vehicle')

$(document).ready(ready)
$(document).on('page:load', ready)