require "rails_helper"

RSpec.describe ProofGuidanceHelper, type: :helper do
  describe "#proof_of_condition_title_and_type" do
    subject(:result) { helper.proof_of_condition_title_and_type(screener) }

    context "when screener has both medical and substance use conditions" do
      let(:screener) do
        instance_double(Screener, preventing_work_medical_condition_yes?: true, preventing_work_drugs_alcohol_yes?: true)
      end

      it "returns the combined title and medical health condition type" do
        expect(result).to eq([I18n.t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title"), I18n.t("views.proof_guidance.edit.condition_medical_health")])
      end
    end

    context "when screener has only a medical condition" do
      let(:screener) do
        instance_double(Screener, preventing_work_medical_condition_yes?: true, preventing_work_drugs_alcohol_yes?: false)
      end

      it "returns the medical condition title and type" do
        expect(result).to eq([I18n.t("views.proof_guidance.edit.proof_of_health_condition_only_title"), I18n.t("views.proof_guidance.edit.condition_medical_health")])
      end
    end

    context "when screener has only a substance use condition" do
      let(:screener) do
        instance_double(Screener, preventing_work_medical_condition_yes?: false, preventing_work_drugs_alcohol_yes?: true)
      end

      it "returns the substance use condition title and type" do
        expect(result).to eq([I18n.t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title"), I18n.t("views.proof_guidance.edit.condition_substance_use")])
      end
    end

    context "when screener has neither condition" do
      let(:screener) do
        instance_double(Screener, preventing_work_medical_condition_yes?: false, preventing_work_drugs_alcohol_yes?: false)
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
