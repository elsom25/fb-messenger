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

  num_friends = 0
  update_num_friends = ->
    num_friends = $form.find('#friends input:checked').length
    $('.num_friends_selected').text num_friends

  update_num_friends()
  $form.find('#friends input:checkbox').on 'change', -> update_num_friends()


  #
  # Update number of groups selected

  num_groups = 0
  update_num_groups = ->
    num_groups = $form.find('#groups input:checked').length
    $('.num_groups_selected').text num_groups

  update_num_groups()
  $form.find('#groups input:checkbox').on 'change', -> update_num_groups()

  #
  # Filters!

  build_list = (list) ->
    arr = []
    arr.push( $("input:checkbox[value='#{JSON.stringify(val)}']") ) for val in list
    return arr

  enable_filter = ($identifier, list) ->
    $identifier.click ->
      $parent = $( this ).parent()
      if $parent.hasClass 'active'
        $.each list, (_, o) -> o.prop( 'checked', false )
      else
        $.each list, (_, o) -> o.prop( 'checked', true )
      $parent.toggleClass 'active'
      update_num_friends()
      update_num_groups()

  $( '.filter' ).each ->
    $this = $( this )
    enable_filter $this, build_list( gon[$this.data( 'gon-id' )] )

  $( '.all_filter' ).each ->
    filter_selector = $( this ).data( 'filter-selector' )
    $( this ).click ->
      if $( this ).parent().hasClass 'active'
        $( filter_selector ).each -> $( this ).click() if $( this ).parent().hasClass 'active'
      else
        $( filter_selector ).each -> $( this ).click() unless $( this ).parent().hasClass 'active'
      $( this ).parent().toggleClass 'active'

  #
  # Update modal on open as needed.

  $('#submitModal').foundation 'reveal',
    open: ->
      $private_msg_list = $('#private_message_list')
      $wall_msg_list = $('#wall_message_list')
      $private_msg_list.empty()
      $wall_msg_list.empty()
      for msg_id in messages
        msg = $("##{msg_id}").val()
        $private_msg_list.append( window.nl2br("<li>hey (name),\n#{msg}</li>") ) if num_friends > 0
        $wall_msg_list.append( window.nl2br("<li>Hey (Name)!\n\n#{msg}</li>") ) if num_groups > 0

      return
