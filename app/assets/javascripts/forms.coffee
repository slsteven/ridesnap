ready = ->

  $(document).ajaxError (event, jqxhr, settings, exception) ->
    $form = switch settings.url
      when '/users' then $("form[data-model='user']")
      when '/sessions' then $("form[data-model='session']")
    $form.render_form_errors JSON.parse(jqxhr.responseText)

  $(document).ajaxSuccess (event, xhr, settings) ->
    $('.modal').modal_success()

$(document).ready(ready)
$(document).on('page:load', ready)

(($) ->
  $.fn.modal_success = ->
    # close modal
    @modal 'hide'
    # clear form input elements
    # todo/note: handle textarea, select, etc
    @find("form input[type='text']").val ''
    # clear error state
    @clear_previous_errors()

  $.fn.render_form_errors = (errors) ->
    @clear_previous_errors()
    model = @data('model')
    # show error messages in input form-group help-block
    for field, messages of errors
      $input = $("input[name='" + model + '[' + field + "]']")
      $input.closest('.form-group').addClass('has-error').find('.help-block').html messages.join(' & ')

  $.fn.clear_previous_errors = ->
    $('.form-group.has-error', this).each ->
      $('.help-block', $(this)).html ''
      $(this).removeClass 'has-error'
) jQuery