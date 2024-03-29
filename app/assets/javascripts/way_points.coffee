$(window).load ->

  $('#header-threshold').waypoint (direction) ->
    if direction == 'down'
      $('header').addClass 'override'
    else if direction == 'up'
      $('header').removeClass 'override'
  , { offset: 60 }

  $('#how-link').waypoint (direction) ->
    if direction == 'down'
      if ($('body').hasClass('home') or $('body').hasClass('how'))
        $('ul li#home').removeClass 'active'
        $('ul li#how').addClass 'active'
    else if direction == 'up'
      if ($('body').hasClass('home') or $('body').hasClass('how'))
        $('ul li#home').addClass 'active'
        $('ul li#how').removeClass 'active'
  , { offset: 90 }
