require "rails_helper"

RSpec.describe Screener, type: :model do
  describe "validations" do
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
  end
end
