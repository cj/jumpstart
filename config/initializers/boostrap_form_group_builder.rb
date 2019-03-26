# frozen_string_literal: true

module BootstrapForm
  module FormGroupBuilder
    extend ActiveSupport::Concern

    private

    # :reek:NilCheck
    def valid?(method)
      object&.respond_to?(method) && object.send(method).present?
    end

    # :reek:ControlParameter
    def form_group_css_options(method, html_options, options)
      css_options = html_options || options

      # Add control_class; allow it to be overridden by :control_class option
      control_classes = css_options.delete(:control_class) { control_class }

      classes = [control_classes, css_options[:class]]

      if error? method
        classes << ' is-invalid'
      elsif valid? method
        classes << ' is-valid'
      end

      css_options[:class] = classes.compact.join ' '

      if options[:label_as_placeholder]
        css_options[:placeholder] = form_group_placeholder options, method
      end

      css_options
    end
  end
end
