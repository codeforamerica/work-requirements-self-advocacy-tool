module ControllerNavigation
  # requires including classes to implement `#navigation_class` which must return a subclass of `ControllerNavigation::ControllerNavigation`
  module NavigableController
    extend ActiveSupport::Concern

    included do
      helper_method :item_index, :next_path, :prev_path
      attr_reader :item_index
      before_action :set_item_index

      class << self
        def show?(intake, item_index: nil)
          true
        end

        def to_param
          controller_name.dasherize
        end

        def navigation_actions
          [:edit]
        end

        def to_path_helper(options = {})
          action = options.delete(:action) || :edit
          full_url = options.delete(:full_url) || false
          Rails.application.routes.url_helpers.url_for({
            controller: controller_path,
            action: action,
            only_path: !full_url,
            # url_for sometimes uses the current path to determine the right URL in some situations,
            # explicitly sending an empty _recall disables that behavior
            _recall: {}
          }.merge(default_url_options).merge(options))
        end
      end
    end

    def set_item_index
      @item_index = params[:item_index]&.to_i
    end

    def item_index
    end

    def navigation_instance
      navigation_class.new(self, item_index: item_index)
    end

    def next_step(&page_filter_block)
      navigation_instance.next(&page_filter_block)
    end

    def next_path(&page_filter_block)
      next_page_info = next_step(&page_filter_block)

      return unless next_page_info&.dig(:controller)
      next_page_controller = next_page_info[:controller]

      options = {action: next_page_controller.navigation_actions.first}
      options[:item_index] = next_page_info[:item_index] if next_page_info&.key? :item_index

      if next_page_info.key? :params
        options.merge!(next_page_info[:params])
      end

      next_page_controller.to_path_helper(options)
    end

    def prev_step(&page_filter_block)
      navigation_instance.prev(&page_filter_block)
    end

    def prev_action
      return unless self.class.navigation_actions.count > 1

      if self.class.navigation_actions.first != action_name.to_sym
        self.class.navigation_actions.first
      end
    end

    def prev_path(&page_filter_block)
      if prev_action
        self.class.to_path_helper({action: prev_action})
      else
        prev_page_info = prev_step(&page_filter_block)

        return unless prev_page_info&.dig(:controller)
        prev_page_controller = prev_page_info[:controller]

        options = {action: prev_page_controller.navigation_actions.first}
        options[:item_index] = prev_page_info[:item_index] if prev_page_info&.key? :item_index
        if prev_page_info.key? :params
          options.merge!(prev_page_info[:params])
        end
        prev_page_controller.to_path_helper(options)
      end
    end
  end
end
