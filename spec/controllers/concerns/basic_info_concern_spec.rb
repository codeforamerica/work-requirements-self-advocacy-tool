require "rails_helper"

RSpec.describe BasicInfoConcern, type: :controller do
  controller(ApplicationController) do
    include BasicInfoConcern

    class << self
      attr_accessor :super_result
    end

    self.super_result = true

    def self.show?(screener)
      super_result
    end

    def index
      head :ok
    end
  end

  describe ".show?" do
    subject { controller.class.show?(screener) }

    def set_super_result(value)
      controller.class.super_result = value
    end

    it_behaves_like "show? with work rules exemption and super"
  end
end
