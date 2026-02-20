module BasicInfoConcern
  extend ActiveSupport::Concern

  def progress_bar_step
    3
  end

  def section_name
    I18n.t("general.basic_information")
  end

  included do
    singleton_class.prepend(ClassMethodsOverride)
  end

  module ClassMethodsOverride
    def show?(screener, item_index: nil)
      screener&.exempt_from_work_rules? && super
    end
  end
end
