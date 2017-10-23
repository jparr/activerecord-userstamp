class PolyComment < ActiveRecord::Base

  stampable polymorphic: true
  belongs_to :poly_post, touch_updater: true

end
