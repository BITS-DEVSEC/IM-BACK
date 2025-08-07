class ClaimSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :claim_number, :description, :claimed_amount, :settlement_amount,
             :incident_date, :incident_time, :incident_location, :incident_type,
             :damage_description, :vehicle_speed, :distance_from_roadside,
             :horn_sounded, :inside_vehicle, :police_notified, :third_party_involved,
             :status, :created_at, :updated_at, :submitted_at,
             :additional_details, :document_urls

  belongs_to :policy
  has_one :claim_driver, serializer: ClaimDriverSerializer
  has_many :claim_timelines, serializer: ClaimTimelineSerializer

  def document_urls
    return {} unless object.documents.attached?

    documents_by_type = {}

    object.documents.each do |document|
      doc_type = document.metadata["document_type"] || "other"
      documents_by_type[doc_type] ||= []
      documents_by_type[doc_type] << {
        id: document.id,
        filename: document.filename.to_s,
        url: url_for(document),
        content_type: document.content_type,
        byte_size: document.byte_size,
        uploaded_at: document.created_at
      }
    end

    documents_by_type
  end

  def settlement_amount
    object.settlement_amount&.to_f
  end

  def claimed_amount
    object.claimed_amount&.to_f
  end
end
