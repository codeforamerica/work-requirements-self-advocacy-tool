class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.params_key
    name.demodulize.underscore
  end

  def self.with_context(context, &block)
    with_options(on: [context, :all], &block)
  end
end
