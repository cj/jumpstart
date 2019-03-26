# frozen_string_literal: true

Dir[Rails.root.join('db/seeds/**/*.rb')].each { |f| require f }

if Rails.env.test?
  return
end

UserSeed.run
