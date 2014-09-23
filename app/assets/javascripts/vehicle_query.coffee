ready = ->
  update_select = (what, where) ->
    $(where + ' option:gt(0)').remove()
    for k, v of JSON.parse(what.responseText)
      $(where).append( $("<option></option>").attr("value", k).text(v) )

  display_query_results = ->
    $('input#schedule-button').attr 'disabled', false

  clear_query_results = ->
    $('input#schedule-button').attr 'disabled', true
    $('#trade-in-value, #ridesnap-value, #buy-it-now-value').text '$0'
    $('.circle.trade-in-value, .circle.ridesnap-value, .circle.buy-it-now-value').width '100%'
    $('form#vehicle-inspection #vehicle_id').val null

  $('#vehicle-query #vehicle_make').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/model_query'
      data:
        make: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #vehicle_model'
      $('#vehicle-query #vehicle_model').prop 'disabled', false
      $('#vehicle-query #vehicle_year').val ''
      $('#vehicle-query #vehicle_year').prop 'disabled', true
      $('#vehicle-query #vehicle_style').val ''
      $('#vehicle-query #vehicle_style').prop 'disabled', true
      $('a#get-a-quote').attr 'disabled', true
      clear_query_results()

  $('#vehicle-query #vehicle_model').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/year_query'
      data:
        make: $('#vehicle-query #vehicle_make').val()
        model: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #vehicle_year'
      $('#vehicle-query #vehicle_year').prop 'disabled', false
      $('#vehicle-query #vehicle_style').val ''
      $('#vehicle-query #vehicle_style').prop 'disabled', true
      $('a#get-a-quote').attr 'disabled', true
      clear_query_results()

  $('#vehicle-query #vehicle_year').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/style_query'
      data:
        make: $('#vehicle-query #vehicle_make').val()
        model: $('#vehicle-query #vehicle_model').val()
        year: $(this).val()
    .complete (opt) ->
      update_select opt, '#vehicle-query #vehicle_style'
      $('#vehicle-query #vehicle_style').prop 'disabled', false
      $('a#get-a-quote').attr 'disabled', true
      clear_query_results()

  $('#vehicle-query #vehicle_style').on 'change', ->
    $('a#get-a-quote').attr 'disabled', false
    clear_query_results()

  $('a#get-a-quote').on 'click', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/query'
      data:
        make: $('#vehicle-query #vehicle_make').val()
        model: $('#vehicle-query #vehicle_model').val()
        year: $('#vehicle-query #vehicle_year').val()
        style: $('#vehicle-query #vehicle_style').val()
        zip: $('#vehicle-query #vehicle_zip_code').val()
    .complete (prices) ->
      prices = JSON.parse(prices.responseText)
      $('#trade-in-value').text '$' + prices.trade_in
      $('#ridesnap-value').text '$' + prices.retail
      $('#buy-it-now-value').text '$' + prices.private_party
      max = Math.max(prices.trade_in, prices.retail, prices.private_party)
      $('.circle.trade-in-value').width Math.round(prices.trade_in/max*100) + '%'
      $('.circle.ridesnap-value').width Math.round(prices.retail/max*100) + '%'
      $('.circle.buy-it-now-value').width Math.round(prices.private_party/max*100) + '%'
      $('form#vehicle-inspection #vehicle_id').val prices.vehicle_id
      $('form#vehicle-query #vehicle_description').val(
        $('#vehicle-query #vehicle_year option:selected').text() + ' ' +
        $('#vehicle-query #vehicle_make option:selected').text() + ' ' +
        $('#vehicle-query #vehicle_model option:selected').text() + ' - ' +
        $('#vehicle-query #vehicle_style option:selected').text()
      )
      display_query_results()

$(document).ready(ready)
$(document).on('page:load', ready)