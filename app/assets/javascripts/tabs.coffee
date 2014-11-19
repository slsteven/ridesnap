ready = ->
  tabCarousel = setInterval(->
    tabs = $("ul#time-money > li")
    active = tabs.filter(".active")
    next = active.next("li")
    goTo = (if next.length then next.find("a") else tabs.eq(0).find("a"))
    goTo.tab 'show'
  , 5000)

  $('.time-money-tabs .tab-content').hover (ev) ->
    clearInterval tabCarousel

  $(document).on 'click', '#scheduled-ride-tab a', ->
    $(this).parent().fadeOut('fast')

$(document).ready(ready)
$(document).on('page:load', ready)