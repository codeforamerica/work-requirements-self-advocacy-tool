# frozen_string_literal: true

module ControllerNavigation
  class ControllerNavigation
    attr_reader :current_controller, :item_index

    class << self
      delegate :first, to: :controllers

      def controllers
        sections.flat_map(&:controllers)
      end

      def pages(screener)
        sections.flat_map { |section| section.pages(screener) }
      end

      def sections
        const_get(:SECTIONS)
      end

      def get_section(controller)
        sections.detect { |section| section.controllers.select { |c| c == controller }.present? }
      end

      def number_of_steps
        sections.count(&:increment_step?)
      end

      def get_progress(controller)
        index = 0
        step = nil
        section = sections.find do |section|
          step = section.steps.detect { |s| s.controllers.include? controller }
          if step.present?
            true
          else
            index += 1 if section.increment_step?
            false
          end
        end
        return if section.nil? || !step.show_steps?
        {
          title: I18n.t(section.title, default: section.title),
          step_number: index,
          number_of_steps: number_of_steps
        }
      end

      def show_progress?(controller_class)
        true
      end

      def scoped_navigation_routes(router)
        # must not be inside a namespace because the controllers' `.controller_path` includes the full namespace,
        # so e.g. wrapping with `namespace :ctc` would look for Ctc::Ctc::XyzController.
        controllers.uniq.each do |controller_class|
          next if controller_class.navigation_actions.length > 1

          {get: :edit, put: :update}.each do |method, action|
            resource_name = controller_class.respond_to?(:resource_name) ? controller_class.resource_name : nil
            if resource_name
              resources resource_name, only: [] do
                member do
                  router.match(
                    "/#{controller_class.to_param}",
                    action: action,
                    controller: controller_class.controller_path,
                    via: method
                  )
                end
              end
            else
              router.match(
                "/#{controller_class.to_param}",
                action: action,
                controller: controller_class.controller_path,
                via: method
              )
            end
          end
        end
        yield if block_given?
      end

      def return_to_review?(return_to_review_param, current_page_info, showable_pages)
        return false if return_to_review_param.blank?

        # Case 1: Always return to review if return_to_review=y
        return true if return_to_review_param == "y"

        if showable_pages.present?
          # Case 2: If there are more showable pages, and we don't see a page matching the return to review param, assume
          # that we passed it and return to review
          showable_pages.none? do |page_info|
            page_info_matches_return_to_review_param?(page_info, return_to_review_param)
          end
        else
          # Case 3: If there are no more showable pages, only return to review if the current page matches the return to
          # review param
          page_info_matches_return_to_review_param?(current_page_info, return_to_review_param)
        end
      end

      def proceeding_out_of_subflow?(current_page_info, next_page_info)
        current_page_info.key?(:index_controller) &&
          (current_page_info[:subflow] != next_page_info[:subflow] ||
            current_page_info[:item_index] != next_page_info[:item_index])
      end

      private

      def page_info_matches_return_to_review_param?(page_info, return_to_review_param)
        page_controller_name = page_info[:controller].name.demodulize.underscore
        possible_matches = [page_controller_name,
          "#{page_controller_name}_#{page_info[:item_index]}",
          page_info[:subflow],
          "#{page_info[:subflow]}_#{page_info[:item_index]}"]
        possible_matches.include? return_to_review_param
      end
    end

    delegate :controllers, to: :class
    delegate :pages, to: :class

    def initialize(current_controller, item_index: nil)
      @current_controller = current_controller
      @item_index = item_index
    end

    def next(controller_class = nil, &filter_block)
      all_pages = pages(current_controller.current_screener)
      current_page_index = index(all_pages, controller_class)
      return unless current_page_index
      pages_until_end = all_pages[current_page_index..]
      return_to_review_param = current_controller.params[:return_to_review_after] ||
        current_controller.params[:return_to_review]

      proceed(pages_until_end, return_to_review_param, &filter_block)
    end

    def prev(&filter_block)
      all_pages = pages(current_controller.current_screener)
      current_page_index = index(all_pages)
      return unless current_page_index
      pages_until_beginning = all_pages[0..current_page_index].reverse
      return_to_review_param = current_controller.params[:return_to_review_before] ||
        current_controller.params[:return_to_review]

      proceed(pages_until_beginning, return_to_review_param, &filter_block)
    end

    private

    def proceed(pages_from_current, return_to_review_param, &filter_block)
      current_page_info = pages_from_current[0]
      remaining_pages = pages_from_current[1..]

      remaining_pages = remaining_pages.filter(&filter_block) if filter_block

      # Ignore all subflow pages with an index page unless we are already in that subflow
      remaining_pages = remaining_pages.filter do |page_info|
        if page_info.key?(:index_controller)
          page_info[:subflow] == current_page_info[:subflow]
        else
          true
        end
      end

      next_showable_page_index = seek(remaining_pages)
      if self.class.return_to_review?(return_to_review_param, current_page_info, remaining_pages[next_showable_page_index..])
        {controller: current_controller.review_controller}
      elsif next_showable_page_index.present?
        next_page_info = remaining_pages[next_showable_page_index]

        if self.class.proceeding_out_of_subflow?(current_page_info, next_page_info)
          # override by jumping to the index page if we are moving out of the subflow for a given item
          next_page_info = {controller: current_page_info[:index_controller], subflow: current_page_info[:subflow]}
        end

        preserve_return_to_review_params(next_page_info)
        next_page_info
      end
    end

    def preserve_return_to_review_params(page_info)
      return_to_review_params = {return_to_review: current_controller.params[:return_to_review],
                                 return_to_review_before: current_controller.params[:return_to_review_before],
                                 return_to_review_after: current_controller.params[:return_to_review_after]}.compact
      page_info[:params] = return_to_review_params if return_to_review_params.present?
    end

    def index(pages, controller_class = nil)
      controller_class ||= current_controller.class
      index = pages.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == item_index }
      if index.nil?
        # if we didn't find a match, try looking for a page with item_index 0
        index = pages.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == 0 }
      end
      index
    end

    def seek(pages)
      pages.index do |page_info|
        page_info[:controller].show?(current_controller.current_screener, item_index: page_info[:item_index])
      end
    end
  end
end
