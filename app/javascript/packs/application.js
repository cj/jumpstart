// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import I18n from '~/i18n'

import 'bootstrap'
import 'data-confirm-modal'
import '~/controllers'

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('~/channels')
require('local-time').start()

window.Rails = Rails

window.I18n = I18n

$(document).on('turbolinks:load', () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
})
