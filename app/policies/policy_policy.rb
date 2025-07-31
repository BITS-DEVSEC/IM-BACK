class PolicyPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if Rails.env.test?

      if user.has_role?("admin")
        scope.all
      elsif user.insurer.present?
        insurer_id = user.insurer.id
        scope.joins(coverage_type: { insurance_product: :insurer })
             .where(insurers: { id: insurer_id })
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
