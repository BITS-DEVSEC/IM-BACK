class QuotationRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :form_data, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer
  belongs_to :insurance_product, serializer: InsuranceProductSerializer
  belongs_to :coverage_type, serializer: CoverageTypeSerializer
  belongs_to :insured_entity, serializer: InsuredEntitySerializer

  def attributes(*args)
    super.merge(request_summary: request_summary)
  end

  private

  def request_summary
    {
      request_type: "#{object.coverage_type&.insurance_type&.name} - #{object.coverage_type&.name}",
      entity_summary: entity_summary,
      user_risk_profile: user_risk_profile,
      estimated_value: estimated_entity_value,
      request_age_days: (Date.current - object.created_at.to_date).to_i,
      completeness_score: calculate_completeness_score
    }
  end

  def entity_summary
    entity = object.insured_entity&.entity
    return "No entity" unless entity

    case entity
    when Vehicle
      "#{entity.year_of_manufacture} #{entity.make} #{entity.model} (#{entity.plate_number})"
    else
      "#{entity.class.name} ##{entity.id}"
    end
  end

  def user_risk_profile
    return {} unless object.user

    user = object.user
    {
      account_age_days: (Date.current - user.created_at.to_date).to_i,
      verified_status: user.verified,
      total_entities: user.insured_entities.count,
      total_policies: user.policies.count,
      total_quotation_requests: user.quotation_requests.count,
      has_active_policies: user.policies.where(status: "active").exists?
    }
  end

  def estimated_entity_value
    entity = object.insured_entity&.entity
    return nil unless entity

    entity.respond_to?(:estimated_value) ? entity.estimated_value : nil
  end

  def calculate_completeness_score
    score = 0
    total_checks = 8

    score += 1 if object.user&.verified
    score += 1 if object.user&.customer&.current_address.present?
    score += 1 if object.form_data.present?
    score += 1 if object.insured_entity&.entity.present?
    score += 1 if object.coverage_type.present?
    score += 1 if estimated_entity_value.present?
    score += 1 if object.user&.customer&.birthdate.present?
    score += 1 if object.status != "draft"

    ((score.to_f / total_checks) * 100).round(1)
  end
end
