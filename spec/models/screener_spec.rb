require "rails_helper"

RSpec.describe Screener, type: :model do
  describe "validations" do
    context "required yes/no" do
      [
        [:receiving_benefits, :is_receiving_snap_benefits],
        [:american_indian, :is_american_indian],
        [:has_child, :has_child],
        [:is_pregnant, :is_pregnant],
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
      end
    end

    context "with_context :is_pregnant" do
      it "requires a due date when is_pregnant is yes" do
        screener = Screener.new(is_pregnant: "yes", pregnancy_due_date: nil)

        screener.valid?(:is_pregnant)
        expect(screener.errors[:pregnancy_due_date]).to be_present

        screener.assign_attributes(pregnancy_due_date: Date.new(2026, 4, 3))
        expect(screener.valid?(:is_pregnant)).to eq true
      end
    end
  end

  describe "before_save" do
    it "clears the due date if is_pregnant changes to no" do
      screener = Screener.create(is_pregnant: "yes", pregnancy_due_date: Date.new(2026, 4, 3))

      screener.update(is_pregnant: "no")

      expect(screener.reload.pregnancy_due_date).to be_nil
    end
  end
end
