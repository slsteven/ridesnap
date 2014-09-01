ready = ->

  $('input.phone').inputmask "(999) 999-9999"

$(document).ready(ready)
$(document).on('page:load', ready)