require "rails_helper"

RSpec.describe Screener, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "validations" do
    context "required yes/no" do
      [
        [:american_indian, :is_american_indian],
        [:living_with_someone, :has_child],
        [:unemployment, :has_unemployment_benefits],
        [:school_enrollment, :is_student]
      ].each do |controller, column|
        it "requires answer to be yes or no in context #{controller}" do
          screener = build(:screener, column => "unfilled")
          screener.valid?(controller)

          expect(screener.errors).to match_array ["#{column.to_s.humanize} #{I18n.t("validations.must_answer_yes_or_no")}"]
        end
      end
    end

    context "with_context :alcohol_treatment_program" do
      it "must not have value longer than AlcoholTreatmentProgramController::CHARACTER_LIMIT, if a value is set" do
        screener = build(:screener,
          alcohol_treatment_program_name: "This is just a test value.")
        # Valid value that is not too long
        expect(screener.valid?(:alcohol_treatment_program)).to eq true

        # Invalid value that is 1 character longer than the limit
        limit = AlcoholTreatmentProgramController::CHARACTER_LIMIT
        text = SecureRandom.alphanumeric(limit + 1)
        screener.assign_attributes(alcohol_treatment_program_name: text)

        screener.valid?(:alcohol_treatment_program)
        expect(screener.errors[:alcohol_treatment_program_name]).to be_present
      end
    end

    context "with_context :location" do
      it "accepts NOT_LISTED as state value" do
        screener = build(:screener, state: "NOT_LISTED", county: nil, zip_code: nil)
        screener.valid?(:location)
        expect(screener.errors[:state]).to be_empty
        expect(screener.errors[:county]).to be_empty
        expect(screener.errors[:zip_code]).to be_empty
      end

      it "does not allow a random state" do
        screener = build(:screener, state: "CA", county: nil, zip_code: nil)
        screener.valid?(:location)
        expect(screener.errors[:state]).to be_present
      end

      context "a state with county-identified offices" do
        let(:screener) { build(:screener, state: "NC") }

        it "is valid with a county from the CSV" do
          screener.assign_attributes(county: "Alleghany County")
          expect(screener.valid?(:location)).to eq true
        end

        it "is invalid when county is nil" do
          screener.assign_attributes(county: nil)
          expect(screener.valid?(:location)).to eq false
          expect(screener.errors[:county]).to be_present
        end

        it "is invalid with a fake county" do
          screener.assign_attributes(county: "Test County")
          expect(screener.valid?(:location)).to eq false
          expect(screener.errors[:county]).to be_present
        end
      end

      context "a state with zip-code-identified offices" do
        let(:screener) { build(:screener, state: "DE") }

        it "is valid with a zip code from the CSV" do
          screener.assign_attributes(zip_code: "19954")
          expect(screener.valid?(:location)).to eq true
        end

        it "is invalid when zip code is nil" do
          screener.assign_attributes(zip_code: nil)
          expect(screener.valid?(:location)).to eq false
          expect(screener.errors[:zip_code]).to eq [I18n.t("validations.zip_code_invalid")]
        end

        it "is invalid with a fake zip code" do
          screener.assign_attributes(zip_code: "12345")
          expect(screener.valid?(:location)).to eq false
          expect(screener.errors[:zip_code]).to eq [I18n.t("validations.zip_code_invalid")]
        end
      end
    end

    context "with_context :date_of_birth" do
      it "requires birth date" do
        screener = build(:screener, birth_date: nil)
        screener.valid?(:date_of_birth)

        expect(screener.errors).to match_array ["Birth date #{I18n.t("validations.date_missing_or_invalid")}"]
      end
    end

    context "with_context :basic_info_details" do
      it "requires first name, last name, and birthday" do
        screener = build(:screener, first_name: nil, last_name: nil)
        screener.valid?(:basic_info_details)

        expect(screener.errors[:first_name]).to eq [I18n.t("validations.first_name_required")]
        expect(screener.errors[:last_name]).to eq [I18n.t("validations.last_name_required")]
      end

      it "requires the phone number to be valid" do
        ["123", "55-111-2222"].each do |phone_number|
          screener = build(:screener, first_name: "Paul", last_name: "Hollywood", birth_date: Date.new(1960, 1, 1), phone_number: phone_number)
          screener.valid?(:basic_info_details)

          expect(screener.errors[:phone_number]).to eq [I18n.t("validations.phone_invalid")]
        end

        screener = build(:screener, first_name: "Paul", last_name: "Hollywood", birth_date: Date.new(1960, 1, 1), phone_number: "415-816-1286")
        expect(screener.valid?(:basic_info_details)).to eq true
      end

      it "must not have value longer than Screener::BASIC_INFO_DETAILS_CHARACTER_LIMIT" do
        [:first_name, :last_name, :middle_name].each do |name|
          # Invalid value that is 1 character longer than the limit
          limit = Screener::BASIC_INFO_DETAILS_CHARACTER_LIMIT
          text = SecureRandom.alphanumeric(limit + 1)
          screener = build(:screener, name => text)

          screener.valid?(:basic_info_details)
          expect(screener.errors[name]).to be_present
        end
      end
    end

    context "with_context :pregnancy" do
      it "requires a due date in the future" do
        screener = build(:screener, is_pregnant: "yes", pregnancy_due_date: Time.now - 2.months)

        screener.valid?(:pregnancy)
        expect(screener.errors[:pregnancy_due_date]).to eq [I18n.t("validations.date_must_be_in_future")]

        screener.assign_attributes(pregnancy_due_date: Time.now + 3.days)
        expect(screener.valid?(:is_pregnant)).to eq true
      end
    end

    context "with_context :caring_for_someone" do
      it "can have both types of dependents" do
        screener = build(:screener, caring_for_child_under_6: "yes", caring_for_disabled_or_ill_person: "yes")
        expect(screener.valid?(:caring_for_someone)).to eq true
      end

      it "cannot have no one and someone" do
        screener = build(:screener,
          caring_for_child_under_6: "no",
          caring_for_disabled_or_ill_person: "yes",
          caring_for_no_one: "yes")
        screener.valid?(:caring_for_someone)

        expect(screener.errors[:caring_for_no_one]).to be_present

        screener = build(:screener,
          caring_for_child_under_6: "yes",
          caring_for_disabled_or_ill_person: "no",
          caring_for_no_one: "yes")
        screener.valid?(:caring_for_someone)

        expect(screener.errors[:caring_for_no_one]).to be_present
      end

      it "must not have value longer than CaringForSomeoneController::CHARACTER_LIMIT, if a value is set" do
        screener = build(:screener,
          additional_care_info: "This is just a test value.")
        # Valid value that is not too long
        expect(screener.valid?(:additional_care_info)).to eq true

        # Invalid value that is 1 character longer than the limit
        limit = CaringForSomeoneController::CHARACTER_LIMIT
        text = SecureRandom.alphanumeric(limit + 1)
        screener.assign_attributes(additional_care_info: text)

        screener.valid?(:caring_for_someone)
        expect(screener.errors[:additional_care_info]).to be_present
      end
    end

    context "with_context :disability_benefits" do
      it "cannot choose a benefit and 'none of the above'" do
        screener = build(:screener,
          receiving_benefits_ssdi: "no",
          receiving_benefits_ssi: "no",
          receiving_benefits_veterans_disability: "yes",
          receiving_benefits_disability_pension: "no",
          receiving_benefits_workers_compensation: "no",
          receiving_benefits_insurance_payments: "yes",
          receiving_benefits_other: "no",
          receiving_benefits_none: "yes")

        screener.valid?(:disability_benefits)
        expect(screener.errors[:receiving_benefits_none]).to be_present

        # valid if receiving_benefits_none is "no"
        screener.assign_attributes(receiving_benefits_none: "no")
        expect(screener.valid?(:disability_benefits)).to eq true

        # valid if everything but receiving_benefits_none is "no"
        screener.assign_attributes(
          receiving_benefits_veterans_disability: "no",
          receiving_benefits_insurance_payments: "no",
          receiving_benefits_none: "yes"
        )
        expect(screener.valid?(:disability_benefits)).to eq true
      end

      it "can only have a write-in answer if 'other' is checked" do
        screener = build(:screener,
          receiving_benefits_other: "no",
          receiving_benefits_write_in: "a different benefit")

        screener.valid?(:disability_benefits)
        expect(screener.errors[:receiving_benefits_write_in]).to be_present

        screener.assign_attributes(
          receiving_benefits_other: "yes",
          receiving_benefits_write_in: "a different benefit"
        )
        expect(screener.valid?(:disability_benefits)).to eq true
      end
    end

    context "with_context :preventing_work_situations" do
      it "cannot choose a situation and 'none of the above'" do
        screener = build(:screener,
          preventing_work_place_to_sleep: "no",
          preventing_work_drugs_alcohol: "yes",
          preventing_work_domestic_violence: "no",
          preventing_work_medical_condition: "no",
          preventing_work_other: "no",
          preventing_work_none: "yes")

        screener.valid?(:preventing_work_situations)
        expect(screener.errors[:preventing_work_none]).to be_present

        # valid if preventing_work_none is "no"
        screener.assign_attributes(preventing_work_none: "no")
        expect(screener.valid?(:preventing_work_situations)).to eq true

        # valid if everything but preventing_work_none is "no"
        screener.assign_attributes(
          preventing_work_drugs_alcohol: "no",
          preventing_work_none: "yes"
        )
        expect(screener.valid?(:preventing_work_situations)).to eq true
      end

      it "can only have a write-in answer if 'other' is checked" do
        screener = build(:screener,
          preventing_work_other: "no",
          preventing_work_write_in: "some other reason")

        screener.valid?(:preventing_work_situations)
        expect(screener.errors[:preventing_work_write_in]).to be_present

        screener.assign_attributes(
          preventing_work_other: "yes",
          preventing_work_write_in: "some other reason"
        )
        expect(screener.valid?(:preventing_work_situations)).to eq true
      end

      it "must not have value longer than AlcoholTreatmentProgramController::CHARACTER_LIMIT, if a value is set" do
        screener = build(:screener,
          preventing_work_write_in: "This is just a test value.")
        # Valid value that is not too long
        expect(screener.valid?(:preventing_work_situations)).to eq true

        # Invalid value that is 1 character longer than the limit
        limit = PreventingWorkSituationsController::CHARACTER_LIMIT
        text = SecureRandom.alphanumeric(limit + 1)
        screener.assign_attributes(preventing_work_write_in: text)

        screener.valid?(:preventing_work_situations)
        expect(screener.errors[:preventing_work_write_in]).to be_present
      end
    end

    context "with_context :basic_info_email" do
      it "requires a valid email" do
        screener = build(:screener, email: "hi.gmail", email_confirmation: "hi.gmail")
        screener.valid?(:basic_info_email)

        expect(screener.errors[:email]).to eq [I18n.t("validations.email_invalid")]
      end

      it "requires a confirmed email" do
        screener = build(:screener, email: "anisha@example.com", email_confirmation: "jenny@example.com")
        screener.valid?(:basic_info_email)

        expect(screener.errors[:email_confirmation]).to eq [I18n.t("validations.email_must_match")]
      end

      it "removes white spaces from the email and confirmation" do
        screener = build(:screener, email: "anisha@example.com ", email_confirmation: " anisha@example.com")
        screener.valid?(:basic_info_email)

        expect(screener.errors).to match_array []
      end

      it "must not have value longer than Screener::BASIC_INFO_EMAIL_CHARACTER_LIMIT" do
        # Invalid value that is 1 character longer than the limit
        limit = Screener::BASIC_INFO_EMAIL_CHARACTER_LIMIT
        text = SecureRandom.alphanumeric(limit + 1)
        screener = build(:screener, email: text)

        screener.valid?(:basic_info_email)
        expect(screener.errors[:email]).to be_present
      end
    end

    context "with_context :basic_info_ssn" do
      it "allows valid last 4 digits of ssn" do
        screener = build(:screener, ssn_last_four: "1234")
        screener.valid?(:basic_info_ssn)

        expect(screener.errors[:ssn_last_four]).to_not be_present
      end

      it "allows empty last 4 digits of ssn" do
        screener = build(:screener, ssn_last_four: "")
        screener.valid?(:basic_info_ssn)

        expect(screener.errors[:ssn_last_four]).to_not be_present
      end

      it "requires valid last 4 digits of ssn" do
        screener = build(:screener, ssn_last_four: "abc")
        screener.valid?(:basic_info_ssn)

        expect(screener.errors[:ssn_last_four]).to be_present

        screener = build(:screener, ssn_last_four: "12de")
        screener.valid?(:basic_info_ssn)

        expect(screener.errors[:ssn_last_four]).to be_present

        screener = build(:screener, ssn_last_four: "123-12-1234")
        screener.valid?(:basic_info_ssn)

        expect(screener.errors[:ssn_last_four]).to be_present
      end
    end

    context "with_context :preventing_work_details" do
      it "must not have a value longer than PreventingWorkDetailsController::CHARACTER_LIMIT, if a value is set" do
        screener = build(:screener,
          preventing_work_additional_info: "This is just a test value.")

        # Valid value that is not too long
        screener.valid?(:preventing_work_details)
        expect(screener.valid?(:preventing_work_additional_info)).to eq true

        # Invalid value that is 1 character longer than the limit
        limit = PreventingWorkDetailsController::CHARACTER_LIMIT
        text = SecureRandom.alphanumeric(limit + 1)
        screener.assign_attributes(preventing_work_additional_info: text)

        screener.valid?(:preventing_work_details)
        expect(screener.errors[:preventing_work_additional_info]).to be_present
      end
    end

    context "with_context :signature" do
      it "requires signature" do
        screener = build(:screener, signature: nil)
        screener.valid?(:signature)

        expect(screener.errors[:signature]).to be_present
      end
    end
  end

  describe "before_save" do
    context "caring for someone attributes" do
      it "clears additional_care_info if caring_for_child_under_6 is no and caring_for_disabled_or_ill_person is no" do
        screener = create(:screener,
          caring_for_child_under_6: "yes",
          caring_for_disabled_or_ill_person: "yes",
          additional_care_info: "i care")

        screener.update(caring_for_child_under_6: "no", caring_for_disabled_or_ill_person: "no")

        expect(screener.reload.additional_care_info).to be_nil
      end
    end

    context "pregnancy attributes" do
      it "clears the due date if is_pregnant changes to no" do
        screener = create(:screener, is_pregnant: "yes", pregnancy_due_date: Date.new(2026, 4, 3))

        screener.update(is_pregnant: "no")

        expect(screener.reload.pregnancy_due_date).to be_nil
      end
    end

    context "employment attributes" do
      it "clears the working_hours and working_weekly_earnings if is_working changes to no" do
        screener = create(:screener, is_working: "yes", working_hours: 7, working_weekly_earnings: 105.50)

        screener.update(is_working: "no")

        expect(screener.reload.working_hours).to be_nil
        expect(screener.reload.working_weekly_earnings).to be_nil
      end
    end

    context "work training attributes" do
      it "clears the program hours and name if is_in_work_training changes to no" do
        screener = create(:screener, is_in_work_training: "yes", work_training_hours: "4", work_training_name: "Choo choo")

        screener.update(is_in_work_training: "no")
        screener.reload
        expect(screener.work_training_hours).to be_nil
        expect(screener.work_training_name).to be_nil
      end
    end

    context "volunteer attributes" do
      it "clears the volunteering_hours and volunteering_org_name if is_volunteer changes to no" do
        screener = create(:screener, is_volunteer: "yes", volunteering_hours: 7, volunteering_org_name: "cfa")

        screener.update(is_volunteer: "no")

        expect(screener.reload.volunteering_hours).to be_nil
        expect(screener.reload.volunteering_org_name).to be_nil
      end
    end

    context "alcohol treatment program attributes" do
      it "clears alcohol_treatment_program_name if is_in_alcohol_treatment_program changes to no" do
        screener = create(:screener, is_in_alcohol_treatment_program: "yes", alcohol_treatment_program_name: "nvm")

        screener.update(is_in_alcohol_treatment_program: "no")

        expect(screener.reload.alcohol_treatment_program_name).to be_nil
      end
    end

    context "with_context :preventing_work_details" do
      it "clears preventing_work_additional_info if no conditions are yes or the none option is yes" do
        screener = create(:screener,
          preventing_work_additional_info: "This is just a test value.",
          preventing_work_drugs_alcohol: "yes")

        screener.update(preventing_work_none: "yes")
        screener.update(preventing_work_drugs_alcohol: "no")

        screener.reload

        expect(screener.preventing_work_additional_info).to be_nil
      end
    end

    context "with_context :location" do
      it "clears county if state selected has no county information" do
        screener = create(:screener,
          state: "NC",
          county: "Alleghany County")
        screener.update(state: "NOT_LISTED")

        expect(screener.reload.county).to be_nil
      end

      it "clears zip if state selected does not index offices by zip" do
        screener = create(:screener,
          state: "DE",
          zip_code: "19954")
        screener.update(state: "NC")

        expect(screener.reload.zip_code).to be_nil
      end
    end
  end

  describe "encryption" do
    it "stores ssn_last_four as encrypted data" do
      screener = create(:screener, ssn_last_four: "4567")
      expect(screener.encrypted_attribute?(:ssn_last_four)).to eq true
      expect(screener.ssn_last_four).to eq "4567"
    end
  end

  describe "#age" do
    it "calculates age from birth_date and current date" do
      screener = build(:screener, birth_date: Date.new(1990, 7, 13))
      travel_to Date.new(2026, 1, 9) do
        expect(screener.age).to eq(35)
      end
    end

    it "accounts for birthday not yet passed this year" do
      screener = build(:screener, birth_date: Date.new(1990, 7, 13))
      travel_to Date.new(2026, 3, 1) do
        expect(screener.age).to eq(35)
      end
    end

    it "accounts for birthday already passed this year" do
      screener = build(:screener, birth_date: Date.new(1990, 7, 13))
      travel_to Date.new(2026, 8, 1) do
        expect(screener.age).to eq(36)
      end
    end

    it "handles leap year birthday on Feb 28 of a non-leap year (birthday considered passed)" do
      screener = build(:screener, birth_date: Date.new(2000, 2, 29))
      travel_to Date.new(2025, 2, 28) do
        expect(screener.age).to eq(25)
      end
    end

    it "handles leap year birthday on Feb 27 of a non-leap year (birthday not yet passed)" do
      screener = build(:screener, birth_date: Date.new(2000, 2, 29))
      travel_to Date.new(2025, 2, 27) do
        expect(screener.age).to eq(24)
      end
    end

    it "handles leap year birthday on Feb 29 of a leap year" do
      screener = build(:screener, birth_date: Date.new(2000, 2, 29))
      travel_to Date.new(2028, 2, 29) do
        expect(screener.age).to eq(28)
      end
    end

    it "handles leap year birthday on Feb 28 of a leap year (birthday not yet passed)" do
      screener = build(:screener, birth_date: Date.new(2000, 2, 29))
      travel_to Date.new(2028, 2, 28) do
        expect(screener.age).to eq(27)
      end
    end

    it "returns nil when birth_date is nil" do
      screener = build(:screener, birth_date: nil)
      expect(screener.age).to be_nil
    end
  end

  describe "#age_qualified?" do
    it "returns true if age is 17 or younger" do
      screener = build(:screener, birth_date: 17.years.ago.to_date + 1.day)
      expect(screener.age_qualified?).to eq true
    end

    it "returns false if age is 18" do
      screener = build(:screener, birth_date: 18.years.ago.to_date)
      expect(screener.age_qualified?).to eq false
    end

    it "returns false if age is 37" do
      screener = build(:screener, birth_date: 37.years.ago.to_date)
      expect(screener.age_qualified?).to eq false
    end

    it "returns false if age is 64" do
      screener = build(:screener, birth_date: 64.years.ago.to_date + 1.day)
      expect(screener.age_qualified?).to eq false
    end

    it "returns true if age is 65" do
      screener = build(:screener, birth_date: 65.years.ago.to_date)
      expect(screener.age_qualified?).to eq true
    end

    it "returns false if birth_date is nil" do
      screener = build(:screener, birth_date: nil)
      expect(screener.age_qualified?).to eq false
    end
  end

  describe "#any_preventing_work?" do
    it "returns false when no preventing work conditions are selected" do
      screener = build(:screener)
      expect(screener.any_preventing_work?).to be false
    end

    Screener::PREVENTING_WORK_ATTRIBUTES.each do |attr|
      it "returns true when #{attr} is yes" do
        screener = build(:screener, attr => "yes")
        expect(screener.any_preventing_work?).to be true
      end
    end
  end

  describe "#complies_with_work_rules?" do
    let(:screener) { create(:screener) }

    context "the total working, volunteering, and training is greater than or equal to 20" do
      before do
        allow(screener).to receive(:total_work_volunteer_and_training_hours).and_return(21)
      end

      it "returns true" do
        expect(screener.complies_with_work_rules?).to be true
      end
    end

    context "the total working, volunteering, and training is less than 20" do
      before do
        allow(screener).to receive(:total_work_volunteer_and_training_hours).and_return(19)
      end

      it "returns false" do
        expect(screener.complies_with_work_rules?).to be false
      end
    end
  end

  describe "#earnings_above_minimum?" do
    it "returns true when working_weekly_earnings >= 217.50" do
      screener = build(:screener, working_weekly_earnings: 217.50)
      expect(screener.earnings_above_minimum?).to be true
    end

    it "returns false when working_weekly_earnings < 217.50" do
      screener = build(:screener, working_weekly_earnings: 217.49)
      expect(screener.earnings_above_minimum?).to be false
    end

    it "returns false when working_weekly_earnings is nil" do
      screener = build(:screener)
      expect(screener.earnings_above_minimum?).to be false
    end
  end

  describe "#full_name" do
    it "joins first_name and last_name" do
      screener = build(:screener, first_name: "Nigella", last_name: "Lawson")
      expect(screener.full_name).to eq("Nigella Lawson")
    end

    it "handles nil first_name" do
      screener = build(:screener, first_name: nil, last_name: "Lawson")
      expect(screener.full_name).to eq("Lawson")
    end

    it "handles nil last_name" do
      screener = build(:screener, first_name: "Nigella", last_name: nil)
      expect(screener.full_name).to eq("Nigella")
    end
  end

  describe "#full_name_with_middle" do
    it "joins first_name, middle_name, and last_name" do
      screener = build(:screener, first_name: "Nigella", middle_name: "Lucy", last_name: "Lawson")
      expect(screener.full_name_with_middle).to eq("Nigella Lucy Lawson")
    end

    it "omits middle_name when nil" do
      screener = build(:screener, first_name: "Nigella", middle_name: nil, last_name: "Lawson")
      expect(screener.full_name_with_middle).to eq("Nigella Lawson")
    end

    it "formats correctly when middle_name is empty string" do
      screener = build(:screener, first_name: "Nigella", middle_name: "", last_name: "Lawson")
      expect(screener.full_name_with_middle).to eq("Nigella Lawson")
    end
  end

  describe "#exempt_from_work_rules?" do
    let(:screener) { build(:screener) }

    it "returns true when has_exemption? is true" do
      allow(screener).to receive(:has_exemption?).and_return(true)
      allow(screener).to receive(:has_earnings_exemption?).and_return(false)

      expect(screener.exempt_from_work_rules?).to eq true
    end

    it "returns true when has_earnings_exemption? is true" do
      allow(screener).to receive(:has_exemption?).and_return(false)
      allow(screener).to receive(:has_earnings_exemption?).and_return(true)

      expect(screener.exempt_from_work_rules?).to eq true
    end

    it "returns false when neither has_exemption? nor has_earnings_exemption? is true" do
      allow(screener).to receive(:has_exemption?).and_return(false)
      allow(screener).to receive(:has_earnings_exemption?).and_return(false)

      expect(screener.exempt_from_work_rules?).to eq false
    end
  end

  describe "#american_indian_exemption_requires_proof?" do
    let(:screener) { build(:screener) }

    it "returns true when state != NC and is_american_indian_yes?" do
      allow(screener).to receive(:state).and_return("DE")
      allow(screener).to receive(:is_american_indian_yes?).and_return(true)

      expect(screener.american_indian_exemption_requires_proof?).to eq true
    end

    it "returns false when state == NC and is_american_indian_yes?" do
      allow(screener).to receive(:state).and_return("NC")
      allow(screener).to receive(:is_american_indian_yes?).and_return(true)

      expect(screener.american_indian_exemption_requires_proof?).to eq false
    end

    it "returns false when state == NC and is_american_indian_no?" do
      allow(screener).to receive(:state).and_return("NC")
      allow(screener).to receive(:is_american_indian_yes?).and_return(false)

      expect(screener.american_indian_exemption_requires_proof?).to eq false
    end

    it "returns false when state != NC and is_american_indian_no?" do
      allow(screener).to receive(:state).and_return("DE")
      allow(screener).to receive(:is_american_indian_yes?).and_return(false)

      expect(screener.american_indian_exemption_requires_proof?).to eq false
    end
  end

  describe "#has_exemption?" do
    it "returns true if age qualified (under 18)" do
      screener = build(:screener, birth_date: 16.years.ago.to_date)
      expect(screener.has_exemption?).to eq true
    end

    it "returns true if age qualified (65 or older)" do
      screener = build(:screener, birth_date: 70.years.ago.to_date)
      expect(screener.has_exemption?).to eq true
    end

    it "returns true if nc_screener is present and exempt" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:exempt_from_work_rules?).and_return(true)

      screener = build(:screener, nc_screener: nc_screener)

      expect(screener.has_exemption?).to eq true
    end

    it "returns false if nc_screener is present but not exempt and no other exemptions apply" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:exempt_from_work_rules?).and_return(false)

      screener = build(:screener, nc_screener: nc_screener)

      expect(screener.has_exemption?).to eq false
    end

    it "returns true if a non-working exemption attribute is yes" do
      screener = build(:screener, is_student: "yes")
      expect(screener.has_exemption?).to eq true
    end

    it "returns false if no exemptions apply" do
      screener = build(:screener,
        birth_date: 30.years.ago.to_date,
        is_working: "no",
        is_student: "no")

      expect(screener.has_exemption?).to eq false
    end
  end

  describe "#receiving_disability_benefits?" do
    it "returns false when no disability benefits are selected" do
      screener = build(:screener)
      expect(screener.receiving_disability_benefits?).to be false
    end

    Screener::DISABILITY_BENEFIT_ATTRIBUTES.each do |benefit|
      it "returns true when #{benefit} is yes" do
        screener = build(:screener, benefit => "yes")
        expect(screener.receiving_disability_benefits?).to be true
      end
    end
  end

  describe "#requires_proof?" do
    let(:screener) { build(:screener) }

    before do
      allow(screener).to receive(:earnings_above_minimum?).and_return(false)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
      allow(screener).to receive(:is_student_yes?).and_return(false)
      allow(screener).to receive(:preventing_work_drugs_alcohol_yes?).and_return(false)
      allow(screener).to receive(:preventing_work_medical_condition_yes?).and_return(false)
      allow(screener).to receive(:receiving_disability_benefits?).and_return(false)
      allow(screener).to receive(:is_in_alcohol_treatment_program_yes?).and_return(false)
      allow(screener).to receive(:american_indian_exemption_requires_proof?).and_return(false)
    end

    it "returns false when everything is false" do
      expect(screener.requires_proof?).to be false
    end

    [
      :is_student_yes?,
      :preventing_work_drugs_alcohol_yes?,
      :preventing_work_medical_condition_yes?,
      :receiving_disability_benefits?,
      :is_in_alcohol_treatment_program_yes?,
      :american_indian_exemption_requires_proof?
    ].each do |method_name|
      it "returns true when only #{method_name} is true" do
        allow(screener).to receive(method_name).and_return(true)

        expect(screener.requires_proof?).to be true
      end
    end

    it "returns true when earnings_above_minimum? is true and not exempt" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(true)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(false)

      expect(screener.requires_proof?).to be true
    end

    it "returns false when earnings_above_minimum? is true but exempt" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(true)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(true)

      expect(screener.requires_proof?).to be false
    end
  end

  describe "#total_work_volunteer_and_training_hours" do
    it "calculates the total number of hours between working, volunteering, and training hours" do
      screener = build(:screener, working_hours: 5, volunteering_hours: 7, work_training_hours: 9)
      expect(screener.total_work_volunteer_and_training_hours).to be 21
    end
  end

  describe "#volunteering?" do
    it "returns false when volunteering_hours is nil" do
      screener = build(:screener)
      expect(screener.volunteering?).to be false
    end

    it "returns false when volunteering_hours is 0" do
      screener = build(:screener, volunteering_hours: 0)
      expect(screener.volunteering?).to be false
    end

    it "returns true when is_volunteer is yes and volunteering_hours is greater than 0" do
      screener = build(:screener, is_volunteer: "yes", volunteering_hours: 1)
      expect(screener.volunteering?).to be true
    end

    it "returns false when is_volunteer is no even with volunteering_hours" do
      screener = build(:screener, is_volunteer: "no", volunteering_hours: 5)
      expect(screener.volunteering?).to be false
    end
  end

  describe "#needs_proof_of_volunteering?" do
    it "returns true when volunteering? is true and state is not NC" do
      screener = build(:screener, state: LocationData::States::DELAWARE)
      allow(screener).to receive(:volunteering?).and_return(true)
      expect(screener.needs_proof_of_volunteering?).to be true
    end

    it "returns false when volunteering? is true and state is NC" do
      screener = build(:screener, state: LocationData::States::NORTH_CAROLINA)
      allow(screener).to receive(:volunteering?).and_return(true)
      expect(screener.needs_proof_of_volunteering?).to be false
    end

    it "returns false when volunteering? is false and state is not NC" do
      screener = build(:screener, state: LocationData::States::DELAWARE)
      allow(screener).to receive(:volunteering?).and_return(false)
      expect(screener.needs_proof_of_volunteering?).to be false
    end

    it "returns false when volunteering? is false and state is NC" do
      screener = build(:screener, state: LocationData::States::NORTH_CAROLINA)
      allow(screener).to receive(:volunteering?).and_return(false)
      expect(screener.needs_proof_of_volunteering?).to be false
    end
  end

  describe "#working_30_or_more_hours?" do
    it "returns true when working_hours >= 30" do
      screener = build(:screener, working_hours: 30)
      expect(screener.working_30_or_more_hours?).to be true
    end

    it "returns false when working_hours < 30" do
      screener = build(:screener, working_hours: 29)
      expect(screener.working_30_or_more_hours?).to be false
    end

    it "returns false when working_hours is nil" do
      screener = build(:screener)
      expect(screener.working_30_or_more_hours?).to be false
    end
  end

  describe "#can_send_screener_results_email?" do
    let(:screener) { create(:screener, email: "test@example.com") }

    context "when the screener has no email" do
      let(:screener) { create(:screener, email: nil) }

      it "returns false" do
        expect(screener.can_send_screener_results_email?).to be false
      end
    end

    context "when the screener has an email and is below the email attempt limit" do
      before do
        (Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED - 1).times do
          create(:outgoing_email, screener: screener, email_type: :screener_results)
        end
      end

      it "returns true" do
        expect(screener.can_send_screener_results_email?).to be true
      end
    end

    context "when the screener has reached the email attempt limit" do
      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: screener, email: screener.email, email_type: :screener_results)
        end
      end

      it "returns false" do
        expect(screener.can_send_screener_results_email?).to be false
      end
    end

    context "when another screener has sent emails to the same address" do
      let(:other_screener) { create(:screener, email: screener.email) }

      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: other_screener, email: screener.email, email_type: :screener_results)
        end
      end

      it "returns true" do
        expect(screener.can_send_screener_results_email?).to be true
      end
    end

    context "when only post_results_survey emails exist" do
      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: screener, email: screener.email, email_type: :post_results_survey)
        end
      end

      it "returns true" do
        expect(screener.can_send_screener_results_email?).to be true
      end
    end

    context "when the screener has reached the email attempt limit for original email, but not new email" do
      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: screener, email: screener.email, email_type: :screener_results)
        end
      end

      it "returns true" do
        screener.update(email: "second@email.biz")
        create(:outgoing_email, screener: screener, email: screener.email, email_type: :screener_results)
        expect(screener.can_send_screener_results_email?).to be true
      end
    end
  end

  describe "#screener_results_email_block_reason" do
    let(:screener) { create(:screener, email: "test@example.com") }

    context "when the screener has no email" do
      let(:screener) { create(:screener, email: nil) }

      it "returns :email_blank" do
        expect(screener.screener_results_email_block_reason).to eq(:email_blank)
      end
    end

    context "when the screener has reached the email attempt limit" do
      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: screener, email: screener.email, email_type: :screener_results)
        end
      end

      it "returns :attempt_limit_reached" do
        expect(screener.screener_results_email_block_reason).to eq(:attempt_limit_reached)
      end
    end

    context "when the screener has reached the email attempt limit for original email, but not new email" do
      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: screener, email: screener.email)
        end
      end

      it "returns nil" do
        screener.update(email: "second@email.biz")
        create(:outgoing_email, screener: screener, email: screener.email)
        expect(screener.screener_results_email_block_reason).to be_nil
      end
    end

    context "when the screener can receive an email" do
      it "returns nil" do
        expect(screener.screener_results_email_block_reason).to be_nil
      end
    end

    context "when another screener reached the limit for the same email address" do
      let(:other_screener) { create(:screener, email: screener.email) }

      before do
        Screener::NUMBER_OF_SCREENER_RESULT_EMAIL_ATTEMPTS_ALLOWED.times do
          create(:outgoing_email, screener: other_screener, email: screener.email, email_type: :screener_results)
        end
      end

      it "returns nil" do
        expect(screener.screener_results_email_block_reason).to be_nil
      end
    end
  end

  describe "#has_earnings_exemption?" do
    it "returns true if working 30 or more hours" do
      screener = build(:screener, is_working: "yes", working_hours: 30)
      expect(screener.has_earnings_exemption?).to eq true
    end

    it "returns true if earning at least 217.50 weekly" do
      screener = build(:screener, is_working: "yes", working_weekly_earnings: 217.50)
      expect(screener.has_earnings_exemption?).to eq true
    end

    it "returns false if working but under both thresholds" do
      screener = build(:screener, is_working: "yes", working_hours: 10, working_weekly_earnings: 100)
      expect(screener.has_earnings_exemption?).to eq false
    end

    it "returns false if not working" do
      screener = build(:screener, is_working: "no")
      expect(screener.has_earnings_exemption?).to eq false
    end
  end

  describe "#office_or_offices_for_zip" do
    context "when the zip code has a single office" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19703", last_name: "Anyone") }

      it "returns that one office as a hash" do
        result = screener.office_or_offices_for_zip
        expect(result).to be_a(Hash)
        expect(result[:name]).to eq("Claymont State Service Center")
      end
    end

    context "when the zip code is split by last name" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19901", last_name: last_name) }

      context "last name falls in A-Smh" do
        let(:last_name) { "Anderson" }

        it "returns the A-Smh office" do
          expect(screener.office_or_offices_for_zip[:name]).to eq("Blue Hen Mall/Corporate Center")
        end
      end

      context "last name falls in Smi-Z" do
        let(:last_name) { "Williams" }

        it "returns the Smi-Z office" do
          expect(screener.office_or_offices_for_zip[:name]).to eq("James W. Williams State Service Center")
        end
      end

      context "last name is at the A-Smh boundary" do
        let(:last_name) { "Smh" }

        it "returns the A-Smh office" do
          expect(screener.office_or_offices_for_zip[:name]).to eq("Blue Hen Mall/Corporate Center")
        end
      end

      context "last name is at the Smi-Z boundary" do
        let(:last_name) { "Smi" }

        it "returns the Smi-Z office" do
          expect(screener.office_or_offices_for_zip[:name]).to eq("James W. Williams State Service Center")
        end
      end

      context "last name is lowercase" do
        let(:last_name) { "anderson" }

        it "still resolves using capitalized comparison" do
          expect(screener.office_or_offices_for_zip[:name]).to eq("Blue Hen Mall/Corporate Center")
        end
      end

      context "last name is blank" do
        let(:last_name) { nil }

        it "returns nil because the office cannot be determined yet" do
          expect(screener.office_or_offices_for_zip).to be_nil
        end
      end
    end

    context "when the zip code has special geo offices" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19720", last_name: "Anyone") }

      it "returns all of the offices as an array" do
        result = screener.office_or_offices_for_zip
        expect(result).to be_an(Array)
        expect(result.size).to be > 1
        expect(result.map { |o| o[:name] }).to include("DeLaWarr State Service Center")
      end
    end
  end

  describe "#office_info_for" do
    context "in a state with county-identified offices" do
      let(:screener) { build(:screener, state: "NC", county: "Durham County") }

      it "returns the requested attribute from the county data" do
        expected = LocationData::Counties.get("NC", "Durham County")[:email]
        expect(screener.office_info_for(:email)).to eq(expected)
      end
    end

    context "in a state with zip-code-identified offices" do
      context "and the zip has a single office" do
        let(:screener) { build(:screener, state: "DE", zip_code: "19703", last_name: "Anyone") }

        it "returns the requested attribute from that office" do
          expect(screener.office_info_for(:name)).to eq("Claymont State Service Center")
        end
      end

      context "and the zip is split by last name" do
        let(:screener) { build(:screener, state: "DE", zip_code: "19901", last_name: "Williams") }

        it "returns the requested attribute from the office matching the last name" do
          expect(screener.office_info_for(:name)).to eq("James W. Williams State Service Center")
        end
      end

      context "and the zip has multiple special geo offices" do
        let(:screener) { build(:screener, state: "DE", zip_code: "19720", last_name: "Anyone") }

        it "raises because a single office cannot be selected" do
          expect {
            screener.office_info_for(:name)
          }.to raise_error(StandardError, /Cannot return office/)
        end
      end
    end
  end

  describe "office accessor methods" do
    let(:screener) { build(:screener, state: "DE", zip_code: "19703", last_name: "Anyone") }
    let(:office) { LocationData::ZipCodes.get_all("DE", "19703").first }

    it "#office_name returns the office name" do
      expect(screener.office_name).to eq(office[:name])
    end

    it "#office_email returns the office email" do
      expect(screener.office_email).to eq(office[:email])
    end

    it "#office_mailing_address returns the mailing address" do
      expect(screener.office_mailing_address).to eq(office[:mailing_address])
    end

    it "#office_phone returns the office phone" do
      expect(screener.office_phone).to eq(office[:phone])
    end

    it "#office_website returns the office website" do
      expect(screener.office_website).to eq(office[:website])
    end

    describe "#office_physical_address" do
      it "returns physical_address when present" do
        allow(screener).to receive(:office_info_for).with(:physical_address).and_return("123 Real St")
        expect(screener.office_physical_address).to eq("123 Real St")
      end

      it "falls back to the mailing address when physical_address is blank" do
        allow(screener).to receive(:office_info_for).with(:physical_address).and_return(nil)
        allow(screener).to receive(:office_info_for).with(:mailing_address).and_return("PO Box 1")
        expect(screener.office_physical_address).to eq("PO Box 1")
      end
    end

    describe "#office_upload_or_portal_email" do
      it "returns upload_portal_or_email when present" do
        allow(screener).to receive(:office_info_for).with(:upload_portal_or_email).and_return("https://upload.example")
        expect(screener.office_upload_or_portal_email).to eq("https://upload.example")
      end

      it "falls back to the office email when upload_portal_or_email is blank" do
        allow(screener).to receive(:office_info_for).with(:upload_portal_or_email).and_return(nil)
        allow(screener).to receive(:office_info_for).with(:email).and_return("office@example.com")
        expect(screener.office_upload_or_portal_email).to eq("office@example.com")
      end
    end
  end

  describe "#offices_to_display" do
    context "for an NC county" do
      let(:screener) { build(:screener, state: "NC", county: "Durham County") }

      it "returns a single-element array with the county office" do
        result = screener.offices_to_display
        expect(result.size).to eq(1)
        expect(result.first[:name]).to eq("Durham County")
        expect(result.first[:subgeography]).to be_nil
      end
    end

    context "for a DE zip with a single office" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19703", last_name: "Anyone") }

      it "returns a single-element array" do
        result = screener.offices_to_display
        expect(result.size).to eq(1)
        expect(result.first[:name]).to eq("Claymont State Service Center")
      end
    end

    context "for a DE zip split by last name" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19901", last_name: "Anderson") }

      it "returns the resolved single office wrapped in an array" do
        result = screener.offices_to_display
        expect(result.size).to eq(1)
        expect(result.first[:name]).to eq("Blue Hen Mall/Corporate Center")
      end
    end

    context "for a DE special_geo zip" do
      let(:screener) { build(:screener, state: "DE", zip_code: "19720", last_name: "Anyone") }

      it "returns all offices with their subgeographies" do
        result = screener.offices_to_display
        expect(result.size).to be > 1
        expect(result.map { |o| o[:subgeography] }).to all(be_present)
      end
    end

    it "falls back physical_address to mailing_address when blank" do
      screener = build(:screener, state: "DE", zip_code: "19703", last_name: "Anyone")
      office = screener.offices_to_display.first
      expect(office[:physical_address]).to eq(office[:mailing_address])
    end

    it "falls back upload_portal_or_email to email when blank" do
      screener = build(:screener, state: "NC", county: "Durham County")
      raw_office = LocationData::Counties.get("NC", "Durham County")
      stubbed = raw_office.merge(upload_portal_or_email: nil, email: "fallback@example.com")
      allow(LocationData::Counties).to receive(:get).with("NC", "Durham County").and_return(stubbed)

      office = screener.offices_to_display.first
      expect(office[:upload_portal_or_email]).to eq("fallback@example.com")
    end
  end
end
