module Forms
  # include in your form controllers!
  # requires that they also implement:
  #   `.attributes_edited` - should return a list of symbols corresponding to attributes on the relevant model
  #   `#next_path` - possibly via Navigable
  module FormController
    extend ActiveSupport::Concern

    included do
      class << self
        def validation_key
          controller_name.to_sym
        end

        def load_model(intake, item_index: nil)
          intake
        end

        def model_valid?(model)
          model.valid?(validation_key)
        end

        def save_model(model)
          model.save(context: validation_key)
        end
      end
    end

    def edit
      @model = self.class.load_model(current_screener, item_index: item_index)
    end

    def update
      @model = self.class.load_model(current_screener, item_index: item_index)
      begin
        @model.assign_attributes(form_params(@model))
      rescue ArgumentError
        self.class.model_valid?(@model)
        render :edit, status: :unprocessable_content
        return
      rescue ActionController::ParameterMissing
        render :edit, status: :bad_request
        return
      end

      if self.class.model_valid?(@model)
        self.class.save_model(@model)
        after_update_success
        track_page_submit(form_params(@model), @model.class)
        redirect_to(next_path)
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def after_update_success
    end

    def form_params(model)
      params.expect(model.class.params_key => self.class.attributes_edited)
    end

    def track_page_submit(submitted_params, model_class)
      pii_attrs = model_class.respond_to?(:pii_attributes) ? model_class.pii_attributes(submitted_params.to_h) : []
      sanitized = submitted_params.to_h.each_with_object({}) do |(key, value), hash|
        if pii_attrs.include?(key.to_sym)
          hash[:"has_#{key}"] = value.present?
        else
          hash[key.to_sym] = value
        end
      end
      send_mixpanel_event(event_name: "page_submit", data: sanitized)
    end
  end
end
