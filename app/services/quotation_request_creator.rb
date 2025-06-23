class QuotationRequestCreator
  def initialize(user:, entity_class:, entity_params:, file_params:, quotation_params:, residence_address_params: nil)
    @user = user
    @entity_class = entity_class
    @entity_params = entity_params
    @file_params = file_params
    @quotation_params = quotation_params
    @residence_address_params = residence_address_params
    @errors = []
  end

  def call
    ActiveRecord::Base.transaction do
      ensure_customer_exists
      handle_residence_address if @residence_address_params.present?

      build_entity
      attach_files if @file_params.present?

      unless @entity.save
        @errors.concat(@entity.errors.full_messages)
        raise ActiveRecord::Rollback
      end

      build_insured_entity
      unless @insured_entity.save
        @errors.concat(@insured_entity.errors.full_messages)
        raise ActiveRecord::Rollback
      end

      build_quotation_request
      unless @quotation_request.save
        @errors.concat(@quotation_request.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end

    @quotation_request if @errors.empty?
  end

  def errors
    @errors
  end

  private

  def ensure_customer_exists
    @customer = @user.customer
    unless @customer
      @errors << "User must have a customer profile"
      raise ActiveRecord::Rollback
    end
  end

  def handle_residence_address
    begin
      @customer.add_residence_address(@residence_address_params)
    rescue ActiveRecord::RecordInvalid => e
      @errors.concat(e.record.errors.full_messages)
      raise ActiveRecord::Rollback
    end
  end

  def build_entity
    @entity = @entity_class.new(@entity_params)
  end

  def attach_files
    @entity_class.file_attachments.each do |attachment_name|
      if @file_params[attachment_name].present?
        @entity.public_send(attachment_name).attach(@file_params[attachment_name])
      end
    end
  end

  def build_insured_entity
    @insured_entity = InsuredEntity.new(
      user: @user,
      insurance_type: CoverageType.find_by(id: @quotation_params[:coverage_type_id])&.insurance_type,
      entity: @entity,
      entity_type: EntityType.find_by!(name: @entity_class.name)
    )
  end

  def build_quotation_request
    @quotation_request = QuotationRequest.new(
      user: @user,
      insured_entity: @insured_entity,
      coverage_type_id: @quotation_params[:coverage_type_id],
      insurance_product_id: @quotation_params[:insurance_product_id],
      form_data: @quotation_params[:form_data] || {},
      status: "pending"
    )
  end
end
