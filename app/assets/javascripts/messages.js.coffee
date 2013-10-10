'use strict'
$ ->
  $('#submitModal').foundation 'reveal',
    open: ->
      num_friends = $('#new_message').find('input:checked').length
      $('#num_people').text num_friends
      return
