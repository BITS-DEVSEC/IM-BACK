module Common
  extend ActiveSupport::Concern
  include Pagination
  include JsonResponse

  included do
    before_action :set_clazz
    before_action :set_object, only: %i[show update]
  end

  def index
    data = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        data, options = incoming
      elsif incoming.instance_of?(Hash)
        options = incoming
      else
        data = incoming
      end
    else
      data = @clazz.all
    end

    total = data.count
    data = data.then(&paginate) if params[:page]

    render_success(nil, data: data, serializer_options: options)
  end

  def show
    data = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        data, options = incoming
      elsif incoming.instance_of?(Hash)
        data = @obj
        options = incoming
      else
        data = incoming
      end
    else
      data = @obj
    end

    render_success(nil, data: data, serializer_options: options)
  end

  def create
    obj = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        obj, options = incoming
      elsif incoming.instance_of?(Hash)
        obj = @clazz.new(model_params)
        options = incoming
      else
        obj = incoming
      end
    else
      obj = @clazz.new(model_params)
    end

    if obj.save
      render_success(nil, data: obj, serializer_options: options, status: :created)
    else
      render_error("errors.validation_failed", errors: obj.errors.full_messages[0], status: :unprocessable_entity)
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def update
    obj = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        obj, options = incoming
      elsif incoming.instance_of?(Hash)
        obj = set_object
        options = incoming
      else
        obj = incoming
      end
    else
      obj = set_object
    end

    if obj.update(model_params)
      render_success(nil, data: obj, serializer_options: options)
    else
      render_error("errors.validation_failed", errors: obj.errors.full_messages[0], status: :unprocessable_entity)
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  private

  def set_clazz
    @clazz = controller_name.classify.constantize
  end

  def set_object
    @obj = @clazz.find(params[:id])
  end

  # This method should be overridden by respective child controllers
  def model_params; end
end
