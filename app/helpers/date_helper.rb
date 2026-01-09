module DateHelper
  def parse_date_params(year, month, day)
    date_values = [year, month, day]
    return nil if date_values.any?(&:blank?)

    begin
      Date.new(*date_values.map(&:to_i))
    rescue ArgumentError => error
      raise error unless error.to_s == "invalid date"
      nil
    end
  end
end
