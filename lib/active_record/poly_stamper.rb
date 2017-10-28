module ActiveRecord::Userstamp
  class PolyStamper
    include ActiveModel::Model
    extend ActiveRecord::Userstamp::Stamper::InstanceMethods
  end
end
