# frozen_string_literal: true

class UserSeed < BaseSeed
  def self.run
    bot = User.new(
      id: bot_id,
      name: bot_name,
      email: bot_email,
    )

    import record: bot, model: User, validate: false
  end
end
