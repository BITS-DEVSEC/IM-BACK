class ClaimsDashboardService
  def initialize(user)
    @user = user
  end

  def dashboard_data
    {
      summary: claim_summary,
      recent_claims: recent_claims_data,
      claims_by_status: claims_by_status_data,
      monthly_trends: monthly_trends_data,
      processing_times: processing_times_data
    }
  end

  private

  attr_reader :user

  def user_claims
    @user_claims ||= begin
      if user.has_role?("admin")
        Claim.all
      elsif user.insurer.present?
        Claim.joins(policy: { coverage_type: { insurance_product: :insurer } })
             .where(insurers: { id: user.insurer.id })
      else
        Claim.joins(:policy).where(policies: { user_id: user.id })
      end
    end
  end

  def claim_summary
    {
      total_claims: user_claims.count,
      pending_claims: user_claims.pending.count,
      approved_claims: user_claims.approved.count,
      rejected_claims: user_claims.rejected.count,
      paid_claims: user_claims.paid.count,
      total_claimed_amount: user_claims.sum(:claimed_amount)&.to_f || 0,
      total_settlement_amount: user_claims.where.not(settlement_amount: nil).sum(:settlement_amount)&.to_f || 0,
      average_processing_time: average_processing_time_days
    }
  end

  def recent_claims_data
    user_claims.recent
              .limit(5)
              .includes(policy: [ :user, :insured_entity, :coverage_type ])
              .map do |claim|
      {
        id: claim.id,
        claim_number: claim.claim_number,
        status: claim.status,
        incident_type: claim.incident_type,
        claimed_amount: claim.claimed_amount&.to_f,
        incident_date: claim.incident_date,
        days_since_submission: claim.days_since_submission,
        policy_number: claim.policy.policy_number
      }
    end
  end

  def claims_by_status_data
    user_claims.group(:status).count
  end

  def monthly_trends_data
    last_12_months = 12.times.map { |i| i.months.ago.beginning_of_month }

    trends = user_claims.where(created_at: 1.year.ago..)
                       .group_by_month(:created_at)
                       .group(:status)
                       .count

    last_12_months.reverse.map do |month|
      month_key = month.strftime("%Y-%m")
      {
        month: month_key,
        draft: trends.dig([ month_key, "draft" ]) || 0,
        pending: trends.dig([ month_key, "pending" ]) || 0,
        approved: trends.dig([ month_key, "approved" ]) || 0,
        rejected: trends.dig([ month_key, "rejected" ]) || 0,
        paid: trends.dig([ month_key, "paid" ]) || 0
      }
    end
  end

  def processing_times_data
    completed_claims = user_claims.where(status: [ "approved", "rejected", "paid" ])
                                 .where.not(submitted_at: nil)

    return {} if completed_claims.empty?

    processing_times = completed_claims.map do |claim|
      next unless claim.submitted_at

      end_time = case claim.status
      when "approved", "rejected"
                   claim.updated_at
      when "paid"
                   claim.updated_at
      end

      (end_time - claim.submitted_at) / 1.day
    end.compact

    return {} if processing_times.empty?

    {
      average_days: processing_times.sum / processing_times.length,
      median_days: median(processing_times),
      fastest_days: processing_times.min,
      slowest_days: processing_times.max
    }
  end

  def average_processing_time_days
    completed_claims = user_claims.where(status: [ "paid" ])
                                 .where.not(submitted_at: nil)

    return 0 if completed_claims.empty?

    total_processing_time = completed_claims.sum do |claim|
      next 0 unless claim.submitted_at
      (claim.updated_at - claim.submitted_at) / 1.day
    end

    (total_processing_time / completed_claims.count).round(1)
  end

  def median(array)
    return 0 if array.empty?

    sorted = array.sort
    length = sorted.length

    if length.odd?
      sorted[length / 2]
    else
      (sorted[length / 2 - 1] + sorted[length / 2]) / 2.0
    end
  end
end
