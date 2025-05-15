class VehicleSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers # Make sure to include this

  attributes :id, :plate_number, :chassis_number, :engine_number, :year_of_manufacture, :make, :model, :estimated_value, :front_view_photo_url, :back_view_photo_url, :left_view_photo_url, :right_view_photo_url, :engine_photo_url, :chassis_number_photo_url, :libre_photo_url

  def front_view_photo_url
    object.front_view_photo.attached? ? url_for(object.front_view_photo) : nil
  end

  def back_view_photo_url
    object.back_view_photo.attached? ? url_for(object.back_view_photo) : nil
  end

  def left_view_photo_url
    object.left_view_photo.attached? ? url_for(object.left_view_photo) : nil
  end

  def right_view_photo_url
    object.right_view_photo.attached? ? url_for(object.right_view_photo) : nil
  end

  def engine_photo_url
    object.engine_photo.attached? ? url_for(object.engine_photo) : nil
  end

  def chassis_number_photo_url
    object.chassis_number_photo.attached? ? url_for(object.chassis_number_photo) : nil
  end

  def libre_photo_url
    object.libre_photo.attached? ? url_for(object.libre_photo) : nil
  end
end
