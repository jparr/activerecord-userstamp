module ActiveRecord::Userstamp::MigrationHelper
  extend ActiveSupport::Concern

  def userstamps(*args)
    config = ActiveRecord::Userstamp.config
    column(config.creator_attribute, :integer, *args)
    column(config.updater_attribute, :integer, *args)
    column(config.deleter_attribute, :integer, *args) if config.deleter_attribute.present?
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  include ActiveRecord::Userstamp::MigrationHelper
end

ActiveRecord::ConnectionAdapters::Table.class_eval do
  include ActiveRecord::Userstamp::MigrationHelper
end
