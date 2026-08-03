require "rails_helper"

RSpec.describe LatinScriptValidator do
  let(:validatable_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :name
      validates :name, latin_script: true

      def self.name
        "ValidatableForLatinScriptSpec"
      end
    end
  end

  it "allows blank values" do
    record = validatable_class.new
    record.name = ""
    expect(record.valid?).to eq true
  end

  it "allows English letters, numbers, and punctuation" do
    record = validatable_class.new
    record.name = "Hello, World! 123"
    expect(record.valid?).to eq true
  end

  it "allows accented Latin characters used in Spanish" do
    record = validatable_class.new
    record.name = "José García-Muñoz"
    expect(record.valid?).to eq true
  end

  it "rejects Arabic script" do
    record = validatable_class.new
    record.name = "احتاج للمواد الغذائية"
    expect(record.valid?).to eq false
    expect(record.errors[:name]).to eq [I18n.t("validations.latin_script_only")]
  end

  it "rejects Chinese script" do
    record = validatable_class.new
    record.name = "你好"
    expect(record.valid?).to eq false
  end

  it "rejects Cyrillic script" do
    record = validatable_class.new
    record.name = "Привет"
    expect(record.valid?).to eq false
  end
end
