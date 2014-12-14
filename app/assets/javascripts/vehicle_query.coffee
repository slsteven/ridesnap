ready = ->
  update_select = (what, where) ->
    $(where + ' option:gt(0)').remove()
    for k, v of JSON.parse(what.responseText)
      $(where).append( $("<option></option>").attr("value", k).text(v) )

  display_query_results = ->
    $('input#schedule-button').attr 'disabled', false

  clear_query_results = ->
    $('input#schedule-button').attr 'disabled', true
    $('#trade-in-value, #ridesnap-value').text '$0'
    $('.circle.trade-in-value, .circle.ridesnap-value, .circle.buy-it-now-value').width '100%'
    $('form#vehicle-inspection #vehicle_id').val null

  get_value = (make, model, year, style, zip) ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/query'
      data:
        make: make
        model: model
        year: year
        style: style
        zip: zip

  $('#vehicle-query #vehicle_make').on 'change', ->
    $.ajax
      type: 'get'
      dataType: 'json'
      url: '/vehicles/model_query'
      data:
        make: $(this).val()
    .complete (opt) ->
      return alert('Vehicle querying is down for maintenance, we apologize for the inconvenience.') if typeof opt.responseJSON is 'number'
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
    get_value(
      $('#vehicle-query #vehicle_make').val()
      $('#vehicle-query #vehicle_model').val()
      $('#vehicle-query #vehicle_year').val()
      $('#vehicle-query #vehicle_style').val()
      $('#vehicle-query #vehicle_zip_code').val()
    )
    .complete (prices) ->
      prices = JSON.parse(prices.responseText)
      trade_in = prices.trade_in
      snap_up = prices.snap_up
      ride_snap = prices.ride_snap
      $('#trade-in-value').text '$' + trade_in
      $('#ridesnap-value').text '$' + ride_snap
      # $('#buy-it-now-value').text '$' + snap_up
      $('#trade_in_value').val trade_in
      $('#ride_snap_value').val ride_snap
      $('#snap_up_value').val snap_up
      max = Math.max(trade_in, ride_snap, snap_up)
      $('.circle.trade-in-value').width Math.round(trade_in/max*100) + '%'
      $('.circle.ridesnap-value').width Math.round(ride_snap/max*100) + '%'
      $('.circle.buy-it-now-value').width Math.round(snap_up/max*100) + '%'
      $('form#vehicle-inspection #vehicle_id').val prices.vehicle_id
      $('form#vehicle-query #pretty_model').val($('#vehicle-query #vehicle_model option:selected').text())
      $('form#vehicle-query #vehicle_description').val($('#vehicle-query #vehicle_style option:selected').text())
      display_query_results()

$(document).ready(ready)
$(document).on('page:load', ready)