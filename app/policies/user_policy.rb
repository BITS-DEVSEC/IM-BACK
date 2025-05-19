class UserPolicy < ApplicationPolicy
  def index?
    user.current_user_can?("read", "users")
  end

  def show?
    return true if record.id == user.id # Users can always see their own profile
    return true if user.has_role?("admin") # Admins can see all profiles
    false # Everyone else (including managers) can only see their own profile
  end

  def create?
    user.current_user_can?("create", "users")
  end

  def update?
    return true if record.id == user.id # Users can always update their own profile
    user.current_user_can?("update", "users")
  end

  def destroy?
    return false if record.id == user.id # Users cannot delete themselves
    user.current_user_can?("delete", "users")
  end

  class Scope < Scope
    def resolve
      return scope.all if Rails.env.test?

      if user.has_role?("admin")
        scope.all # admin can read all users
      else
        scope.where(id: user.id)
      end
    end
  end
end
