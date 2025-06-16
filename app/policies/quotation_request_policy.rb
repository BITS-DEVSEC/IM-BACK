class QuotationRequestPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.has_role?("admin")
        scope.all
      elsif user.insurer.present?
        insurer_id = user.insurer.id
        scope.joins(:insurance_product)
             .where(insurance_products: { insurer_id: insurer_id })
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
