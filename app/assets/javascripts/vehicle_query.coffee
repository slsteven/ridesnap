ready = ->
  update_select = (what, where) ->
    $(where + ' option:gt(0)').remove()
    for k, v of JSON.parse(what.responseText)
      $(where).append( $("<option></option>").attr("value", k).text(v) )

  $('#vehicle-query #make').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/model_query'
      data:
        make: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #model'
      $('#vehicle-query #model').prop 'disabled', false
      $('#vehicle-query #year').val ''
      $('#vehicle-query #year').prop 'disabled', true
      $('#vehicle-query #style').val ''
      $('#vehicle-query #style').prop 'disabled', true
      $('a#get-a-quote').attr 'disabled', true

  $('#vehicle-query #model').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/year_query'
      data:
        make: $('#vehicle-query #make').val()
        model: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #year'
      $('#vehicle-query #year').prop 'disabled', false
      $('#vehicle-query #style').val ''
      $('#vehicle-query #style').prop 'disabled', true
      $('a#get-a-quote').attr 'disabled', true

  $('#vehicle-query #year').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/style_query'
      data:
        make: $('#vehicle-query #make').val()
        model: $('#vehicle-query #model').val()
        year: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #style'
      $('#vehicle-query #style').prop 'disabled', false
      $('a#get-a-quote').attr 'disabled', true

  $('#vehicle-query #style').on 'change', ->
    $('a#get-a-quote').attr 'disabled', false

  $('a#get-a-quote').on 'click', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/query'
      data:
        make: $('#vehicle-query #make').val()
        model: $('#vehicle-query #model').val()
        year: $('#vehicle-query #year').val()
        style: $('#vehicle-query #style').val()
        zip: $('#vehicle-query #zip').val()
    .complete (prices) ->
      prices = JSON.parse(prices.responseText)
      $('#trade-in-value').text '$' + prices.trade_in
      $('#ridesnap-value').text '$' + prices.retail
      $('#buy-it-now-value').text '$' + prices.private_party
      max = Math.max(prices.trade_in, prices.retail, prices.private_party)
      $('.circle.trade-in-value').width Math.round(prices.trade_in/max*100) + '%'
      $('.circle.ridesnap-value').width Math.round(prices.retail/max*100) + '%'
      $('.circle.buy-it-now-value').width Math.round(prices.private_party/max*100) + '%'
      $('span#selected-make').text $('#vehicle-query #make option:selected').text()
      $('span#selected-model').text $('#vehicle-query #model option:selected').text()
      $('span#selected-year').text $('#vehicle-query #year option:selected').text()
      $('span#selected-style').text $('#vehicle-query #style option:selected').text()
      $('form#vehicle-inspection #vehicle_id').val prices.vehicle_id

$(document).ready(ready)
$(document).on('page:load', ready)