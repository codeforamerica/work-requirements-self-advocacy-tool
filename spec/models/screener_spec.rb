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

    context "with_context :email" do
      it "requires a valid email" do
        screener = Screener.new(email: "hi.gmail", email_confirmation: "hi.gmail")
        screener.valid?(:email)

        expect(screener.errors).to match_array ["Email is invalid"]
      end

      it "requires a confirmed email" do
        screener = Screener.new(email: "anisha@example.com", email_confirmation: "jenny@example.com")
        screener.valid?(:email)

        expect(screener.errors).to match_array ["Email confirmation doesn't match Email"]
      end

      it "removed white spaces from the email and confirmation" do
        screener = Screener.new(email: "anisha@example.com ", email_confirmation: " anisha@example.com")
        screener.valid?(:email)

        expect(screener.errors).to match_array []
      end
    end
  end
end
