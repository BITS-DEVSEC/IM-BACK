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

    # Apply eager loading if defined
    data = data.includes(eager_load_associations) if eager_load_associations.present?

    policy_class_name = "#{@clazz.name}Policy"

    # Check if the policy class exists to apply policy scope
    if Object.const_defined?(policy_class_name)
      begin
        data = policy_scope(@clazz)
        # Reapply eager loading after policy scope
        data = data.includes(eager_load_associations) if eager_load_associations.present?
      rescue => e
        Rails.logger.warn("PolicyScope failed for #{policy_class_name}: #{e.message}")
      end
    end

    # Apply filters
    if respond_to?(:filter_fields, true) && params[:filter].present?
      data = apply_filters(data, filter_fields)
    end

    total = data.count
    data = data.then(&paginate) if params[:page]

    # Add actionspecific serializer includes
    includes = get_serializer_includes_for_action(:index)
    options[:include] = includes if includes.present?

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

    if data.is_a?(@clazz) && eager_load_associations.present?
      data = @clazz.includes(eager_load_associations).find(params[:id])
    end

    includes = get_serializer_includes_for_action(:show)
    options[:include] = includes if includes.present?

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
      obj = @clazz.includes(eager_load_associations).find(obj.id) if eager_load_associations.present?

      includes = get_serializer_includes_for_action(:create)
      options[:include] = includes if includes.present?

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
      obj = @clazz.includes(eager_load_associations).find(obj.id) if eager_load_associations.present?

      includes = get_serializer_includes_for_action(:update)
      options[:include] = includes if includes.present?

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
    if eager_load_associations.present?
      @obj = @clazz.includes(eager_load_associations).find(params[:id])
    else
      @obj = @clazz.find(params[:id])
    end
  end

  # Override in controllers to define what to eager load
  def eager_load_associations
    []
  end

  # Override in controllers to define serializer includes
  def serializer_includes
    {}
  end

  def get_serializer_includes_for_action(action)
    includes = serializer_includes

    if includes.is_a?(Hash)
      includes[action] || includes[:default] || []
    else
      includes.present? ? includes : []
    end
  end

  # This method should be overridden by respective child controllers
  def model_params; end

  def apply_filters(scope, allowed_fields = [])
    return scope if params[:filter].blank? || allowed_fields.empty?

    filter_params = params[:filter].to_unsafe_h.slice(*allowed_fields.map(&:to_s))

    filter_params.reduce(scope) do |filtered_scope, (key, value)|
      next filtered_scope if value.blank?

      if filtered_scope.klass.column_names.include?(key)
        filtered_scope.where(key => value) # Direct column filtering
      elsif filtered_scope.klass.respond_to?("by_#{key}")
        filtered_scope.public_send("by_#{key}", value) # Scope method with by _ prefix
      elsif filtered_scope.klass.respond_to?(key)
        filtered_scope.public_send(key, value) # Named scope
      else
        filtered_scope
      end
    end
  end
end
