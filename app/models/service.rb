# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :user

  Devise.omniauth_configs.keys.each do |provider|
    scope provider, -> { where provider: provider }
  end

  def client
    send "#{provider}_client"
  end

  def expired?
    expires_at? && expires_at <= Time.zone.now
  end

  def access_token
    send "#{provider}_refresh_token!", super if expired?
    super
  end

  def twitter_client
    Twitter::REST::Client.new twitter_client_config
  end

  def twitter_client_config
    secrets = Rails.application.secrets

    {
      consumer_key: secrets.twitter_app_id,
      consumer_secret: twitter_app_secret,
      access_token: access_token,
      access_token_secret: access_token_secret,
    }
  end

  # def twitter_refresh_token!(token); end
end
