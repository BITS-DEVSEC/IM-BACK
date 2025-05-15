module PolicyScope
  extend ActiveSupport::Concern

  def policy_scope(scope)
    policy_class = "#{scope.name}Policy".constantize

    raise NameError, "Policy class #{scope.name}Policy not found" unless policy_class

    policy_class::Scope.new(current_user, scope).resolve
  rescue NameError => e
    Rails.logger.error("Policy class not found: #{e.message}")
    raise
  end
end
