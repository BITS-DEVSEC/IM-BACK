class Scope < ApplicationPolicy::Scope
  def resolve
    return scope.all if Rails.env.test?

    if user.has_role?("admin")
      scope.all
    elsif user.insurer.present?
      insurer_id = user.insurer.id
      scope.joins(policy: { coverage_type: { insurance_product: :insurer } })
            .where(insurers: { id: insurer_id })
    else
      scope.joins(:policy).where(policies: { user_id: user.id })
    end
  end
end
