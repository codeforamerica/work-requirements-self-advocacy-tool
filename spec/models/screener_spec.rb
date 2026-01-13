require "rails_helper"

RSpec.describe Screener, type: :model do
  describe "validations" do
    context "required yes/no" do
      [
        [:receiving_benefits, :is_receiving_snap_benefits],
        [:american_indian, :is_american_indian],
        [:has_child, :has_child],
        [:has_unemployment_benefits, :has_unemployment_benefits]
      ].each do |controller, column|
        it "requires answer to be yes or no in context #{controller}" do
          screener = Screener.new(column => "unfilled")
          screener.valid?(controller)

          expect(screener.errors).to match_array ["#{column.to_s.humanize} #{I18n.t("validations.must_answer_yes_or_no")}"]
        end
      end
    end

    context "with_context :language_preference" do
      it "requires language preferences to be filled out" do
        screener = Screener.new(language_preference_spoken: "unfilled", language_preference_written: "unfilled")
        screener.valid?(:language_preference)

        expect(screener.errors).to match_array ["Language preference spoken must be english or spanish", "Language preference written must be english or spanish"]
      end
    end

    context "with_context :personal_information" do
      it "requires first name, last name, birth date, and phone number" do
        screener = Screener.new(first_name: nil, last_name: nil, birth_date: nil, phone_number: nil)
        screener.valid?(:personal_information)

        expect(screener.errors).to match_array [
          "First name can't be blank",
          "Last name can't be blank",
          "Birth date can't be blank",
          "Phone number can't be blank"
        ]
      end

      it "requires the phone number to be valid" do
        ["123", "55-111-2222"].each do |phone_number|
          screener = Screener.new(first_name: "Paul", last_name: "Hollywood", birth_date: Date.new(1960, 1, 1), phone_number: phone_number)
          screener.valid?(:personal_information)

          expect(screener.errors).to match_array ["Phone number is invalid"]
        end

        screener = Screener.new(first_name: "Paul", last_name: "Hollywood", birth_date: Date.new(1960, 1, 1), phone_number: "415-816-1286")
        expect(screener.valid?(:personal_information)).to eq true
      end
    end

    context "with_context :caring_for_someone" do
      it "can have both types of dependents" do
        screener = Screener.new(caring_for_child_under_6: "yes", caring_for_disabled_or_ill_person: "yes")
        expect(screener.valid?(:caring_for_someone)).to eq true
      end

      it "cannot have no one and someone" do
        screener = Screener.new(
          caring_for_child_under_6: "no",
          caring_for_disabled_or_ill_person: "yes",
          caring_for_no_one: "yes"
        )
        screener.valid?(:caring_for_someone)

        expect(screener.errors[:caring_for_no_one]).to be_present

        screener = Screener.new(
          caring_for_child_under_6: "yes",
          caring_for_disabled_or_ill_person: "no",
          caring_for_no_one: "yes"
        )
        screener.valid?(:caring_for_someone)

        expect(screener.errors[:caring_for_no_one]).to be_present
      end
    end

    context "with_context :disability_benefits" do
      it "cannot choose a benefit and 'none of the above'" do
        screener = Screener.new(
          receiving_benefits_ssdi: "no",
          receiving_benefits_ssi: "no",
          receiving_benefits_veterans_disability: "yes",
          receiving_benefits_disability_pension: "no",
          receiving_benefits_workers_compensation: "no",
          receiving_benefits_insurance_payments: "no",
          receiving_benefits_other: "yes",
          receiving_benefits_none: "yes"
        )

        screener.valid?(:disability_benefits)
        expect(screener.errors[:receiving_benefits_none]).to be_present

        # valid if receiving_benefits_none is "no"
        screener.assign_attributes(receiving_benefits_none: "no")
        expect(screener.valid?(:disability_benefits)).to eq true

        # valid if everything but receiving_benefits_none is "no"
        screener.assign_attributes(
          receiving_benefits_veterans_disability: "no",
          receiving_benefits_other: "no",
          receiving_benefits_none: "yes"
        )
        expect(screener.valid?(:disability_benefits)).to eq true
      end
    end
  end
end
