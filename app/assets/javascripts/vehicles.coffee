ready = ->

	# $('.hoverable .overlay').click ->
	#   $(this).toggleClass 'hover'
	$('.js-report-row').on 'mouseover', ->
		index = $(this).index()

		parent = $(this).parents('.report-option')
		parent.find('.js-content-images img').hide()
		parent.find('.js-content-images .js-report-img-' + index).show()
		parent.find('.js-content-comments span').hide()
		parent.find('.js-content-comments .js-report-comment-' + index).show()

	$('.js-report-row').on 'mouseout', ->
		parent = $(this).parents('.report-option')
		parent.find('.js-content-images img').removeAttr('style')
		parent.find('.js-content-comments span').removeAttr('style')

$(document).ready(ready)
$(document).on('page:load', ready)