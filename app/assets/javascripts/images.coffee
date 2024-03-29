ready = ->
  $('#fileupload').fileupload
    add: (e, data) ->
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      if types.test(file.type) or types.test(file.name)
        data.context = $(tmpl('template-upload', file))
        $('#fileupload').append data.context
        data.submit()
      else
        alert file.name + ' is not a gif, jpeg, or png image file'

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100)
        data.context.find('.bar').css('width', progress + '%')

    done: (e, data) ->
      file = data.files[0]
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name)
      to = $('#fileupload').data('post')
      content = {}
      content[$('#fileupload').data('as')] = file.name
      $.post to, content
      data.context.remove() if data.context

    fail: (e, data) ->
      alert data.files[0].name + ' failed to upload.'
      console.log 'Upload failed:'
      console.log data

$(document).ready(ready)
$(document).on('page:load', ready)