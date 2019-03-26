# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

RAILS_CORS_ORIGINS = ENV.fetch('RAILS_CORS_ORIGINS') { '' }.split(',')

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*RAILS_CORS_ORIGINS)

    # https://github.com/rails/rails/issues/31523#issuecomment-473255555
    resource '*',
      headers: :any,
      methods: [:post, :options],
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      credentials: true
  end
end
