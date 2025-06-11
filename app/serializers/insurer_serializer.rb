class InsurerSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :description, :contact_email, :contact_phone, :api_endpoint, :api_key, :logo_url

  def logo_url
    object.logo.attached? ? url_for(object.logo) : nil
  end
end
