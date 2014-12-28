ready = ->

  $('input.phone').inputmask "(999) 999-9999"

  $('.best_in_place').best_in_place()

  $('.snapup-popup').popover()

  $('.owl-carousel').owlCarousel
    items: 1
    itemsScaleUp: true

  $('.owl-carousel-index-page').owlCarousel
    itemsCustom: [[0, 1], [768, 2], [992, 3], [1200, 4]]
    itemsScaleUp: true
    pagination: false

  # fills

  viewportUnitsBuggyfill.init()

  objectFit.polyfill
    selector: '.carousel-inner img'
    fittype: 'cover' # either contain, cover, fill or none

$(document).ready(ready)
$(document).on('page:load', ready)
