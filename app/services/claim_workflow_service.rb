class ClaimWorkflowService
  def initialize(claim, current_user)
    @claim = claim
    @current_user = current_user
  end

  def can_perform_action?(action)
    case action.to_s
    when "submit"
      claim.status == "draft" && user_owns_claim?
    when "approve"
      claim.status == "pending" && user_can_process_claims?
    when "reject"
      claim.status == "pending" && user_can_process_claims?
    when "pay"
      claim.status == "approved" && user_can_process_claims?
    when "edit"
      [ "draft", "pending" ].include?(claim.status) &&
      (user_owns_claim? || user_can_process_claims?)
    when "delete"
      claim.status == "draft" && user_owns_claim?
    when "upload_documents"
      [ "draft", "pending", "approved" ].include?(claim.status) &&
      (user_owns_claim? || user_can_process_claims?)
    when "view"
      user_owns_claim? || user_can_process_claims? || current_user.has_role?("admin")
    else
      false
    end
  end

  def available_actions
    actions = []

    actions << "view" if can_perform_action?("view")
    actions << "edit" if can_perform_action?("edit")
    actions << "submit" if can_perform_action?("submit")
    actions << "approve" if can_perform_action?("approve")
    actions << "reject" if can_perform_action?("reject")
    actions << "pay" if can_perform_action?("pay")
    actions << "delete" if can_perform_action?("delete")
    actions << "upload_documents" if can_perform_action?("upload_documents")

    actions
  end

  def next_possible_statuses
    case claim.status
    when "draft"
      [ "pending" ]
    when "pending"
      if user_can_process_claims?
        [ "approved", "rejected" ]
      else
        []
      end
    when "approved"
      if user_can_process_claims?
        [ "paid" ]
      else
        []
      end
    else
      []
    end
  end

  def status_display_info
    {
      "draft" => {
        label: "Draft",
        color: "gray",
        description: "Claim is being prepared"
      },
      "pending" => {
        label: "Pending Review",
        color: "yellow",
        description: "Claim is under review"
      },
      "approved" => {
        label: "Approved",
        color: "green",
        description: "Claim has been approved for payment"
      },
      "rejected" => {
        label: "Rejected",
        color: "red",
        description: "Claim has been rejected"
      },
      "paid" => {
        label: "Paid",
        color: "blue",
        description: "Claim has been settled and paid"
      }
    }[claim.status] || { label: claim.status.humanize, color: "gray", description: "" }
  end

  def required_documents_for_status(status)
    case status
    when "pending"
      base_documents = [ "drivers_license" ]

      case claim.incident_type
      when "collision"
        base_documents + [ "accident_photos", "police_report" ]
      when "theft"
        base_documents + [ "police_report" ]
      when "fire"
        base_documents + [ "accident_photos", "fire_department_report" ]
      else
        base_documents
      end
    else
      []
    end
  end

  def validation_errors_for_submission
    errors = []

    # Basic field validation
    errors << "Description is required" if claim.description.blank?
    errors << "Claimed amount is required" if claim.claimed_amount.blank?
    errors << "Incident date is required" if claim.incident_date.blank?
    errors << "Incident type is required" if claim.incident_type.blank?

    # Driver information validation
    errors << "Driver name is required" if claim.claim_driver.name.blank?
    errors << "Driver phone is required" if claim.claim_driver.phone.blank?

    # Document validation
    required_docs = required_documents_for_status("pending")
    required_docs.each do |doc_type|
      unless has_document_type?(doc_type)
        errors << "#{doc_type.humanize} document is required"
      end
    end

    errors
  end

  def self.bulk_status_update(claim_ids, new_status, current_user, settlement_amounts = {})
    results = { success: [], failed: [] }

    claim_ids.each do |claim_id|
      begin
        claim = Claim.find(claim_id)
        workflow = new(claim, current_user)

        if workflow.can_perform_action?(status_action_map[new_status])
          settlement_amount = settlement_amounts[claim_id.to_s]

          if claim.update(
            status: new_status,
            settlement_amount: settlement_amount
          )
            results[:success] << {
              id: claim_id,
              claim_number: claim.claim_number
            }
          else
            results[:failed] << {
              id: claim_id,
              errors: claim.errors.full_messages
            }
          end
        else
          results[:failed] << {
            id: claim_id,
            errors: [ "Not authorized to update this claim" ]
          }
        end
      rescue ActiveRecord::RecordNotFound
        results[:failed] << { id: claim_id, errors: [ "Claim not found" ] }
      rescue StandardError => e
        results[:failed] << { id: claim_id, errors: [ e.message ] }
      end
    end

    results
  end

  private

  attr_reader :claim, :current_user

  def user_owns_claim?
    claim.policy.user_id == current_user.id
  end

  def user_can_process_claims?
    return true if current_user.has_role?("admin")
    return true if current_user.has_role?("manager")
    return true if current_user.insurer.present? &&
                   claim.policy.coverage_type.insurance_product&.insurer_id == current_user.insurer.id
    false
  end

  def has_document_type?(doc_type)
    return false unless claim.documents.attached?

    claim.documents.any? do |doc|
      doc.metadata["document_type"] == doc_type
    end
  end

  def self.status_action_map
    {
      "pending" => "submit",
      "approved" => "approve",
      "rejected" => "reject",
      "paid" => "pay"
    }
  end
end
