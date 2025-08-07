class ClaimTimelineSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :description, :occurred_at, :metadata,
             :formatted_occurred_at, :user_name, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  def formatted_occurred_at
    object.formatted_occurred_at
  end

  def user_name
    object.user_name
  end
end
