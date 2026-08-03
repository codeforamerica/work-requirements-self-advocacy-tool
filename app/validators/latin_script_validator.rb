class LatinScriptValidator < ActiveModel::EachValidator
  PATTERN = /\A[\p{Latin}\p{Common}\p{Inherited}]*\z/

  def validate_each(record, attribute, value)
    return if value.blank?
    return if value.match?(PATTERN)

    record.errors.add(attribute, :latin_script_only, message: I18n.t("validations.latin_script_only"))
  end
end
