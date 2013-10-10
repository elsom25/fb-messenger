'use strict'
$ ->
  $(document).foundation()
  $.meow message:$(el), duration:7500 for el in $('.rails_flash')
