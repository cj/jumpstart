# frozen_string_literal: true

class BaseSeed
  def self.bot
    Rails.application.credentials
  end

  def self.bot_id
    bot[:id] || ENV['BOT_ID']
  end

  def self.bot_name
    bot[:name] || ENV['BOT_NAME'] || 'Bot'
  end

  def self.bot_email
    bot[:email] || ENV['BOT_EMAIL'] || 'bot@localhost'
  end

  # :reek:BooleanParameter
  def self.import(model:, records: [], record: nil, validate: true, options: {})
    if record
      records.push record
    end

    records.map do |current_record|
      current_record[:created_by_id] = bot_id
    end

    method = "import#{validate ? '!' : ''}"

    model.public_send(method, records, {
      on_duplicate_key_ignore: true,
      validate: validate,
    }.merge(options),)
  end
end
