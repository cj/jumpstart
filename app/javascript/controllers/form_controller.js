import { Controller } from 'stimulus'
import { debounce, capitalize } from 'lodash'

const ERROR_CLASS = 'invalid-feedback'
const ERROR_TAG = 'div'

const INPUT_ERROR_CLASS = 'is-invalid'
const INPUT_VALID_CLASS = 'is-valid'
const INPUT_BLACKLIST = ['file', 'reset', 'submit', 'button']
const INPUT_CONTAINER = 'form-group'
const INPUT_ERROR_FIELD_NAME = 'data-error-field-name'

const VALIDITY_TYPES = [
  'badInput',
  'customError',
  'patternMismatch',
  'rangeOverflow',
  'rangeUnderflow',
  'stepMismatch',
  'tooLong',
  'tooShort',
  'typeMismatch',
  'valid',
  'valueMissing',
]

const ACTIVE_MODEL_ERRORS_TYPE_MAP = {
  valueMissing: 'blank',
  typeMismatch: 'invalid',
}

export default class extends Controller {
  connect() {
    const { form, onKeyup, onSubmit, onAjaxSuccess, onAjaxBefore, onAjaxError, onAjaxComplete } = this

    // If the form was submitted via ajax we want to focus on the first error returned.
    this.firstInvalidField.focus()

    form.dataset.remote = true
    form.setAttribute('novalidate', true)
    form.addEventListener('keyup', onKeyup, true)
    form.addEventListener('submit', onSubmit)
    form.addEventListener('ajax:before', onAjaxBefore)
    form.addEventListener('ajax:success', onAjaxSuccess)
    form.addEventListener('ajax:error', onAjaxError)
    form.addEventListener('ajax:complete', onAjaxComplete)
  }

  disconnect() {
    const { form, onKeyup, onSubmit, onAjaxSuccess, onAjaxBefore, onAjaxError, onAjaxComplete } = this

    form.removeEventListener('keyup', onKeyup)
    form.removeEventListener('submit', onSubmit)
    form.removeEventListener('ajax:before', onAjaxBefore)
    form.removeEventListener('ajax:success', onAjaxSuccess)
    form.removeEventListener('ajax:error', onAjaxError)
    form.removeEventListener('ajax:complete', onAjaxComplete)
  }

  onAjaxError = event => {
    console.log(event)
  }

  onAjaxComplete = _event => {}

  onAjaxBefore = event => {
    if (this.validateForm() && this.form.method === 'get') {
      event.preventDefault() // do not perform regular sumbit
      event.stopPropagation() // do not let regular remote handler see this

      const form = $(this.form)
      Turbolinks.visit(`${form.attr('action')}?${form.serialize()}`)
    }
  }

  onKeyup = debounce(event => this.validateField(event.target), 250)

  onSubmit = event => {
    if (this.validateForm() && this.form.method !== 'get') {
      Turbolinks.controller.history.push(window.location.href)
    } else {
      event.preventDefault() // do not perform regular sumbit
      event.stopPropagation() // do not let regular remote handler see this

      this.firstInvalidField.focus()
    }
  }

  onAjaxSuccess = event => {
    if (this.form.method === 'get') return

    const response = event.detail[0]

    if (response.substring(0, 10) === 'Turbolinks') {
      return
    }

    Turbolinks.clearCache()

    $('body').html(response.match(/<body[^>]*>([\s\S]*?)<\/body>/i)[1])

    Turbolinks.dispatch('turbolinks:load')

    window.scroll(0, 0)
  }

  validateForm() {
    let isValid = true

    // Not using `find` because we want to validate all the fields
    this.formFields.forEach(field => {
      if (this.shouldValidateField(field) && !this.validateField(field)) isValid = false
    })

    return isValid
  }

  validateField(field) {
    if (!this.shouldValidateField(field) || !field.hasAttribute('required')) {
      return true
    }

    const isValid = field.checkValidity()

    field.classList.toggle(INPUT_ERROR_CLASS, !isValid)

    this.refreshErrorForInvalidField(field, isValid)

    if (isValid) {
      field.classList.add(INPUT_VALID_CLASS)
    }

    return isValid
  }

  shouldValidateField = field => {
    return !field.disabled && !INPUT_BLACKLIST.includes(field.type) && field.willValidate
  }

  refreshErrorForInvalidField(field, isValid) {
    const fieldContainer = field.closest(`.${INPUT_CONTAINER}`)

    this.removeExistingErrorMessage(field, fieldContainer)

    if (!isValid) {
      this.showErrorForInvalidField(field, fieldContainer)
    }
  }

  removeExistingErrorMessage = (field, fieldContainer) => {
    if (!fieldContainer) {
      return
    }

    // const label = fieldContainer.querySelector('label')
    //
    // if (label) {
    //   const labelHTML = label.dataset.labelHTML
    //
    //   if (labelHTML) label.innerHTML = labelHTML
    //
    //   label.classList.remove('text-danger')
    //   return
    // }

    const existingErrorMessageElement = fieldContainer.querySelector(`.${ERROR_CLASS}`)

    if (existingErrorMessageElement) {
      existingErrorMessageElement.parentNode.removeChild(existingErrorMessageElement)
    }
  }

  showErrorForInvalidField(field, _fieldContainer) {
    // const label = fieldContainer.querySelector('label')
    //
    // if (label) {
    //   this.setLabelError(label, field)
    // } else {
    field.insertAdjacentHTML('afterend', this.buildFieldErrorHtml(field))
    // }
  }

  setLabelError(label, field) {
    const dataLabelHTML = label.dataset.labelHTML
    const labelHTML = dataLabelHTML || label.innerHTML
    const errorMessage = this.getFieldErrorMessage(field)

    if (!dataLabelHTML) label.dataset.labelHTML = dataLabelHTML

    label.innerHTML = `${labelHTML} ${errorMessage}`
    label.classList.add('text-danger')
  }

  buildFieldErrorHtml(field) {
    const errorMessage = this.getFieldErrorMessage(field)
    return `<${ERROR_TAG} class="${ERROR_CLASS}">${errorMessage}</${ERROR_TAG}>`
  }

  getFieldErrorMessage = field => {
    const { validity, validationMessage, name } = field
    const htmlErrorType = VALIDITY_TYPES.find(type => validity[type])
    const messageKey = ACTIVE_MODEL_ERRORS_TYPE_MAP[htmlErrorType]

    let errorField = field.getAttribute(INPUT_ERROR_FIELD_NAME)

    if (!errorField) {
      errorField = name
        .trim()
        // Extract the field from the name i.e. project[description] becomes description
        .replace(/.+\b(\w+)(?:\S|)$/i, '$1')
        // Replace any none word with a space i.e. Password_confirmation becomes Password confirmation
        .replace(/[^a-z]/i, ' ')
        // cleanup spaces
        .replace(/\s{2,}/i, ' ')

      errorField = capitalize(errorField)

      field.setAttribute(INPUT_ERROR_FIELD_NAME, errorField)
    }

    const i18nMessage = I18n.t(`errors.messages.${messageKey}`, {
      defaultValue: validationMessage,
    })

    const errorMessage = `${errorField} ${i18nMessage}`

    return errorMessage
  }

  get formFields() {
    return Array.from(this.element.elements)
  }

  get firstInvalidField() {
    return (
      this.formFields.find(field => {
        return !field.checkValidity() || field.classList.contains(INPUT_ERROR_CLASS)
      }) || { focus: () => null }
    )
  }

  get form() {
    return this.element
  }
}
