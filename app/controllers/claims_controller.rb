class ClaimsController < ApplicationController
  include Common

  def create
    policy = Policy.find(params[:policy_id]) if params[:policy_id].present?
    unless policy
      render_error("claims.errors.policy_required", status: :unprocessable_entity)
      return
    end

    unless policy.user_id == current_user.id
      render_error("claims.errors.policy_not_owned", status: :forbidden)
      return
    end

    super do
      claim = @clazz.new(model_params)
      claim.policy = policy
      claim.claim_number = generate_claim_number
      claim.status = "draft"

      [ claim, { serializer: ClaimSerializer } ]
    end
  end

  def update
    claim = set_object

    unless claim.can_be_updated_by_user?
      render_error("claims.errors.cannot_update_claim", status: :forbidden)
      return
    end

    super do
      handle_document_attachments(claim) if params[:documents].present?

      [ claim, { serializer: ClaimSerializer } ]
    end
  end

  def update_status
    claim = @clazz.find(params[:id])

    unless current_user.has_role?("admin") || current_user.has_role?("insurer")
      render_error("claims.errors.insufficient_privileges", status: :forbidden)
      return
    end

    if claim.update(status: params[:status], settlement_amount: params[:settlement_amount])
      ClaimTimeline.create_event(claim, "status_changed", current_user,
        description: "Status changed to #{params[:status]}")

      render_success(
        "claims.status_updated_successfully",
        data: claim,
        serializer_options: { serializer: ClaimSerializer }
      )
    else
      render_error(
        "errors.validation_failed",
        errors: claim.errors.full_messages.first,
        status: :unprocessable_entity
      )
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def submit
    claim = @clazz.find(params[:id])

    unless claim.can_be_submitted?
      render_error("claims.errors.cannot_submit_claim", status: :unprocessable_entity)
      return
    end

    if claim.update(status: "pending", submitted_at: Time.current)
      ClaimTimeline.create_event(claim, "submitted", current_user)

      render_success(
        "claims.submitted_successfully",
        data: claim,
        serializer_options: { serializer: ClaimSerializer }
      )
    else
      render_error(
        "errors.validation_failed",
        errors: claim.errors.full_messages.first,
        status: :unprocessable_entity
      )
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def dashboard
    dashboard_service = ClaimsDashboardService.new(current_user)
    render_success(nil, data: dashboard_service.dashboard_data)
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def upload_documents
    claim = @clazz.find(params[:id])

    upload_service = DocumentUploadService.new(
      claim: claim,
      document_type: params[:document_type],
      files: params[:files],
      current_user: current_user
    )

    if upload_service.upload_documents
      ClaimTimeline.create_event(claim, "document_uploaded", current_user,
        metadata: { document_type: params[:document_type] })

      documents = DocumentUploadService.get_uploaded_documents(claim, params[:document_type])
      render_success(
        "claims.documents.uploaded_successfully",
        data: documents
      )
    else
      render_error(
        "errors.validation_failed",
        errors: upload_service.errors.full_messages.first,
        status: :unprocessable_entity
      )
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def documents
    claim = @clazz.find(params[:id])

    documents = DocumentUploadService.get_uploaded_documents(claim, params[:document_type])
    render_success(nil, data: documents)
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def remove_document
    claim = @clazz.find(params[:id])

    result = DocumentUploadService.remove_document(claim, params[:document_id], current_user)

    if result[:success]
      ClaimTimeline.create_event(claim, "document_removed", current_user,
        metadata: { document_id: params[:document_id] })

      render_success("claims.documents.removed_successfully")
    else
      render_error("errors.standard_error", error: result[:error])
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def workflow
    claim = @clazz.find(params[:id])

    workflow_service = ClaimWorkflowService.new(claim, current_user)

    workflow_data = {
      current_status: claim.status,
      available_actions: workflow_service.available_actions,
      next_possible_statuses: workflow_service.next_possible_statuses,
      status_info: workflow_service.status_display_info,
      required_documents: workflow_service.required_documents_for_status(claim.status),
      validation_errors: workflow_service.validation_errors_for_submission,
      timeline: claim.claim_timelines.recent.limit(10)
    }

    render_success(nil, data: workflow_data)
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def bulk_update_status
    claim_ids = params[:claim_ids] || []
    new_status = params[:status]
    settlement_amounts = params[:settlement_amounts] || {}

    results = ClaimWorkflowService.bulk_status_update(
      claim_ids,
      new_status,
      current_user,
      settlement_amounts
    )

    render_success(
      "claims.bulk_update_completed",
      data: results
    )
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  # Custom action to delete a claim (only draft claims)
  def destroy
    claim = @clazz.find(params[:id])

    unless claim.status == "draft"
      render_error("claims.errors.cannot_delete_submitted_claim", status: :forbidden)
      return
    end

    if claim.destroy
      render_success("claims.deleted_successfully")
    else
      render_error(
        "errors.validation_failed",
        errors: claim.errors.full_messages.first,
        status: :unprocessable_entity
      )
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  private

  def eager_load_associations
    [ policy: [ :user, :insured_entity, :coverage_type ], claim_driver: [], claim_timelines: [ :user ] ]
  end

  def serializer_includes
    {
      default: [ :policy, :claim_driver ],
      show: [ :policy, :claim_driver, :claim_timelines ],
      index: [ :policy ]
    }
  end

  def filter_fields
    [ :status, :policy_id, :claim_number, :from_date, :to_date, :incident_type ]
  end

  def model_params
    permitted_params = params.require(:payload).permit(
      :description, :claimed_amount, :incident_date, :incident_location,
      :incident_time, :incident_type, :damage_description, :vehicle_speed,
      :distance_from_roadside, :horn_sounded, :inside_vehicle, :police_notified,
      :third_party_involved, :additional_details,
      claim_driver_attributes: [
        :name, :phone, :license_number, :age, :occupation, :address,
        :city, :subcity, :kebele, :house_number, :license_issuing_region,
        :license_issue_date, :license_expiry_date, :license_grade
      ]
    )

    if permitted_params[:claim_driver_attributes].present?
      permitted_params
    else
      permitted_params.except(:claim_driver_attributes)
    end
  end

  def generate_claim_number
    "CL-#{Date.current.year}-#{SecureRandom.hex(4).upcase}"
  end

  def handle_document_attachments(claim)
    return unless params[:documents].is_a?(Hash)

    params[:documents].each do |doc_type, files|
      next unless files.present?

      Array(files).each do |file|
        claim.documents.attach(
          io: file,
          filename: "#{doc_type}_#{Time.current.to_i}_#{file.original_filename}",
          content_type: file.content_type,
          metadata: { document_type: doc_type }
        )
      end
    end
  end
end
