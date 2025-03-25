module JsonResponse
  extend ActiveSupport::Concern

  def serialize(data, options = {})
    if data.is_a?(Hash)
      data.transform_values { |value| serialize(value, options) }
    else
      ActiveModelSerializers::SerializableResource.new(data, options)
    end
  end

  def json_success(message_key = nil, data: nil, status: :ok, serializer_options: {}, **options)
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

  def json_error(message_key, status: :unprocessable_entity, errors: nil, **options)
    response = {
      success: false,
      error: I18n.t(message_key)
    }
    response[:errors] = errors if errors
    response.merge!(options)

    render json: response, status: status
  end
end
