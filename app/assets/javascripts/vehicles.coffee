ready = ->

  $('.hoverable .overlay').click ->
    $(this).toggleClass 'hover'

$(document).ready(ready)
$(document).on('page:load', ready)