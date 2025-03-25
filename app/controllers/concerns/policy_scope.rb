module PolicyScope
  extend ActiveSupport::Concern

  def policy_scope(scope)
    policy_class = "#{scope.name}Policy".constantize
    policy_class::Scope.new(current_user, scope).resolve
  end
end
