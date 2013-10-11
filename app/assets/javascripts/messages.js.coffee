'use strict'
$ ->

  $form    = $('#new_message')
  messages = []

  #
  # Update number of messages typed

  $form.find('textarea').on 'input propertychange', ->
    message_exists = ($msg) -> $msg.val().length > 0
    message_found  = (found) -> found >= 0

    $msg    = $(this)
    $msg_id = $msg.attr( 'id' )
    found   = jQuery.inArray( $msg_id, messages )

    messages.push( $msg_id ) if message_exists( $msg ) and not message_found( found )
    messages.splice( found, 1 ) if not message_exists( $msg ) and message_found( found )

    $('.num_messages_selected').text messages.length

  #
  # Update number of friends selected

  $form.find('input:checkbox').on 'change', ->
    num_friends = $form.find('input:checked').length
    $('.num_friends_selected').text num_friends

  $('#submitModal').foundation 'reveal',
    open: ->
      $msg_list = $('#message_list')
      $msg_list.empty()
      for msg_id in messages
        msg = $("##{msg_id}").val()
        $msg_list.append( "<li>#{window.nl2br("hey (NAME),\n#{msg}")}</li>" )

      return
