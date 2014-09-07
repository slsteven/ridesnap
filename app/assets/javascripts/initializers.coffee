ready = ->

  $('input.phone').inputmask "(999) 999-9999"

  $('.best_in_place').best_in_place()

  viewportUnitsBuggyfill.init()

$(document).ready(ready)
$(document).on('page:load', ready)