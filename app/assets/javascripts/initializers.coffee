ready = ->

  $('input.phone').inputmask "(999) 999-9999"

  $('.best_in_place').best_in_place()

  $('.snapup-popup').popover()

  # fills

  viewportUnitsBuggyfill.init()

  objectFit.polyfill
    selector: '.carousel-inner img'
    fittype: 'cover' # either contain, cover, fill or none

$(document).ready(ready)
$(document).on('page:load', ready)