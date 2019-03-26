# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def new_with_session(hash, _session)
      UserPolicy.new current_user, scope.new(hash)
    end
  end
end
