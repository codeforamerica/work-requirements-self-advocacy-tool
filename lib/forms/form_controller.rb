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
      @model.assign_attributes(form_params(@model))
      if self.class.model_valid?(@model)
        self.class.save_model(@model)
        after_update_success
        redirect_to(next_path)
      else
        render :edit
      end
    end

    private

    def after_update_success
    end

    def form_params(model)
      params.expect(model.class.params_key => self.class.attributes_edited)
    end
  end
end
