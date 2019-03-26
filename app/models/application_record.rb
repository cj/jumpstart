# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true

  before_validation :set_created_by_and_updated_by

  protected

  def set_created_by_and_updated_by
    bot = Rails.application.credentials.bot || {}
    bot_id = bot[:id] || ENV['BOT_ID']

    if id
      self.updated_by_id ||= bot_id
    else
      self.created_by_id ||= bot_id
    end
  end
end
