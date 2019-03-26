# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
    flash_type_string = flash_type.to_s

    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info',
    }.stringify_keys[flash_type_string] || flash_type_string
  end
end
