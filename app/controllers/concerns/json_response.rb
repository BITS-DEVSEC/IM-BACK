module JsonResponse
  extend ActiveSupport::Concern

  def serialize(data, options = {})
    return data unless data.respond_to?(:as_json) || data.is_a?(Hash) || data.is_a?(Array)

    case data
    when Hash
      data.transform_values { |value| serialize(value, options) }
    when ActiveModelSerializers::SerializableResource
      data.as_json
    when ActiveRecord::Base, Array
      ActiveModelSerializers::SerializableResource.new(data, options).as_json
    else
      data.as_json
    end
  end

  def render_success(message_key = nil, data: nil, status: :ok, serializer_options: {}, **options)
    response = { success: true }
    response[:message] = I18n.t(message_key) if message_key

    if data
      serialized_data = serialize(data, serializer_options)
      response[:data] = serialized_data
    end

    if params[:page] && data.respond_to?(:count)
      response[:page] = params[:page]
      response[:total] = data.count
    end

    response.merge!(options)
    render json: response, status: status
  end

  def render_error(message_key, status: :unprocessable_entity, errors: nil, **options)
    response = {
      success: false,
      error: I18n.t(message_key)
    }
    response[:errors] = errors if errors
    response.merge!(options)

    render json: response, status: status
  end
end
