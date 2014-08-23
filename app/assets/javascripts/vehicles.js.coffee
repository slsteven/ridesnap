$(document).on 'ready page:load', ->
  circleSize()
  $(window).resize ->
    circleSize()

heightAdj = (obj) ->
  width = $(obj).width()
  $(obj).css height: width
  inner = $('.words', obj)
  $(inner).css marginTop: width/2 - $(inner).height()/1.5

circleSize = ->
  circles = $('div.circle')
  heightAdj cir for cir in circles
