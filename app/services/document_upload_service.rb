class DocumentUploadService
  include ActiveModel::Model

  ALLOWED_DOCUMENT_TYPES = %w[
    accident_photos
    drivers_license
    police_report
    medical_report
    repair_estimate
    other_supporting_documents
  ].freeze

  ALLOWED_FILE_TYPES = %w[
    image/jpeg
    image/png
    image/gif
    application/pdf
    video/mp4
    video/quicktime
  ].freeze

  MAX_FILE_SIZE = 10.megabytes
  MAX_FILES_PER_TYPE = 10

  attr_accessor :claim, :document_type, :files, :current_user

  validates :claim, presence: true
  validates :document_type, presence: true, inclusion: { in: ALLOWED_DOCUMENT_TYPES }
  validates :files, presence: true
  validate :validate_file_constraints
  validate :validate_user_permissions

  def upload_documents
    return false unless valid?

    begin
      uploaded_files = []

      Array(files).each do |file|
        claim.documents.attach(
          io: file,
          filename: generate_filename(file),
          content_type: file.content_type,
          metadata: {
            document_type: document_type,
            uploaded_by: current_user.id,
            original_filename: file.original_filename,
            upload_timestamp: Time.current.to_i
          }
        )

        uploaded_files << claim.documents.last
      end

      # Log the upload activity
      Rails.logger.info(
        "Documents uploaded - Claim: #{claim.claim_number}, " \
        "Type: #{document_type}, Count: #{uploaded_files.length}, " \
        "User: #{current_user.email}"
      )

      true
    rescue StandardError => e
      errors.add(:base, "Document upload failed: #{e.message}")
      false
    end
  end

  def self.get_uploaded_documents(claim, document_type = nil)
    documents = claim.documents.attached? ? claim.documents : []

    if document_type.present?
      documents = documents.select { |doc| doc.metadata["document_type"] == document_type }
    end

    documents.map do |document|
      {
        id: document.id,
        filename: document.filename.to_s,
        content_type: document.content_type,
        byte_size: document.byte_size,
        document_type: document.metadata["document_type"],
        uploaded_by: document.metadata["uploaded_by"],
        uploaded_at: document.created_at,
        url: Rails.application.routes.url_helpers.url_for(document)
      }
    end
  end

  def self.remove_document(claim, document_id, current_user)
    document = claim.documents.find(document_id)

    # Check permissions
    unless can_remove_document?(claim, current_user)
      return { success: false, error: "Not authorized to remove documents" }
    end

    document_info = {
      filename: document.filename.to_s,
      document_type: document.metadata["document_type"]
    }

    document.purge

    Rails.logger.info(
      "Document removed - Claim: #{claim.claim_number}, " \
      "File: #{document_info[:filename]}, User: #{current_user.email}"
    )

    { success: true, message: "Document removed successfully" }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def validate_file_constraints
    return unless files.present?

    file_array = Array(files)

    # Check number of files
    if file_array.length > MAX_FILES_PER_TYPE
      errors.add(:files, "Cannot upload more than #{MAX_FILES_PER_TYPE} files at once")
      return
    end

    file_array.each_with_index do |file, index|
      # Check file size
      if file.size > MAX_FILE_SIZE
        errors.add(:files, "File #{index + 1} is too large. Maximum size is #{MAX_FILE_SIZE / 1.megabyte}MB")
      end

      # Check file type
      unless ALLOWED_FILE_TYPES.include?(file.content_type)
        errors.add(:files, "File #{index + 1} has unsupported format: #{file.content_type}")
      end

      # Additional validation for specific document types
      validate_document_type_constraints(file, index)
    end
  end

  def validate_document_type_constraints(file, index)
    case document_type
    when "accident_photos"
      unless file.content_type.start_with?("image/", "video/")
        errors.add(:files, "Accident photos must be images or videos")
      end
    when "drivers_license", "police_report", "medical_report", "repair_estimate"
      unless file.content_type.start_with?("image/") || file.content_type == "application/pdf"
        errors.add(:files, "#{document_type.humanize} must be an image or PDF")
      end
    end
  end

  def validate_user_permissions
    return unless claim.present? && current_user.present?

    unless can_upload_documents?
      errors.add(:base, "You are not authorized to upload documents for this claim")
    end
  end

  def can_upload_documents?
    return true if current_user.has_role?("admin")
    return true if claim.policy.user_id == current_user.id
    return true if current_user.insurer.present? &&
                   claim.policy.coverage_type.insurance_product&.insurer_id == current_user.insurer.id
    false
  end

  def self.can_remove_document?(claim, current_user)
    return true if current_user.has_role?("admin")
    return true if claim.policy.user_id == current_user.id && claim.can_be_updated_by_user?
    return true if current_user.insurer.present? &&
                   claim.policy.coverage_type.insurance_product&.insurer_id == current_user.insurer.id
    false
  end

  def generate_filename(file)
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    extension = File.extname(file.original_filename)
    "#{document_type}_#{claim.claim_number}_#{timestamp}_#{SecureRandom.hex(4)}#{extension}"
  end
end
