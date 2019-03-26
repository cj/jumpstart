# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_user, :record

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def logged_in?
    current_user.present?
  end
  alias_method :logged_in, :logged_in?

  def deny?
    false
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    true
  end
  alias_method :create, :create?

  def new?
    create?
  end

  def update?
    record.created_by_id == current_user.id
  end
  alias_method :update, :update?

  def edit?
    update?
  end

  def destroy?
    record.created_by_id == current_user.id
  end
  alias_method :destroy, :destroy?

  def scope
    @__scope ||= Scope.new current_user, record
  end

  def method_missing(method, *args, &block)
    record.public_send(method, *args, &block)
  end

  class Scope
    attr_reader :current_user, :scope, :original_scope, :record

    def initialize(current_user, scope)
      @current_user = current_user
      @original_scope = scope
      @scope = scope

      unless scope.is_a? Class
        @record = scope
      end
    end

    def current_roles
      (current_user&.roles&.map(&:name)) || []
    end

    def resolve
      unless current_roles.include? 'superuser'
        return scope unless scope.is_a? Class

        @scope = if scope.name == 'User'
          scope.where id: current_user.id
        else
          scope.where created_by: current_user
        end
      end

      scope
    end

    def create(values)
      save values
    end

    def create!(values)
      save! values
    end

    def save(values = nil)
      @record ||= scope.new values
      set_default_columns
      pp record
      record.save
      record
    end

    def save!(values = nil)
      @record ||= scope.new values
      set_default_columns
      record.save!
      record
    end

    def no_scope
      original_scope
    end

    def method_missing(method, *args, &block)
      resolve.public_send(method, *args, &block)
    end

    private

    def set_default_columns
      return unless current_user

      if record.id
        @record.updated_by = current_user
      else
        @record.created_by = current_user
      end
    end
  end
end
