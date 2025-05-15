module Authorization
  extend ActiveSupport::Concern

  included do
    class NotAuthorizedError < StandardError; end

    rescue_from NotAuthorizedError do |exception|
      render_error("errors.forbidden", status: :forbidden, errors: exception.message)
    end
  end

  def authorize!(action, resource)
    unless current_user_can?(action, resource)
      raise NotAuthorizedError, "You are not authorized to perform this action on #{resource}."
    end
  end

  def current_user_can?(action, resource)
    return false unless current_user

    @user_permissions ||= current_user.roles
      .joins(role_permissions: :permission)
      .pluck("permissions.action", "permissions.resource")
      .uniq

    @user_permissions.include?([ action.to_s, resource.to_s ])
  end

  def verify_admin!
    unless current_user.has_role?("admin")
      raise NotAuthorizedError, "You must be an admin to perform this action."
    end
  end

  def authorize_index!(resource)
    authorize!("read", resource)
  end

  def authorize_show!(resource)
    authorize!("read", resource)
  end

  def authorize_create!(resource)
    authorize!("create", resource)
  end

  def authorize_update!(resource)
    authorize!("update", resource)
  end

  def authorize_destroy!(resource)
    authorize!("delete", resource)
  end
end
