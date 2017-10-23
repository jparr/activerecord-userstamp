ActiveRecord::Base.establish_connection

ActiveRecord::Schema.define(:version => 0) do
  # Users are created and updated by other Users
  create_table :users, :force => true do |t|
    t.column :name,           :string
    t.column :creator_id,     :integer
    t.column :created_on,     :datetime
    t.column :updater_id,     :integer
    t.column :updated_at,     :datetime
  end

  # People are created and updated by Users
  create_table :people, :force => true do |t|
    t.column :name,           :string
    t.column :creator_id,     :integer
    t.column :created_on,     :datetime
    t.column :updater_id,     :integer
    t.column :updated_at,     :datetime
  end

  # Posts are created and updated by People
  create_table :posts, :force => true do |t|
    t.column :title,          :string
    t.column :creator_id,     :integer
    t.column :created_on,     :datetime
    t.column :updater_id,     :integer
    t.column :updated_at,     :datetime
    t.column :deleter_id,     :integer
    t.column :deleted_at,     :datetime
  end

  # Comments are created and updated by People
  # and also use non-standard foreign keys.
  create_table :comments, :force => true do |t|
    t.column :post_id,        :integer
    t.column :comment,        :string
    t.column :created_by,     :integer
    t.column :created_at,     :datetime
    t.column :updated_by,     :integer
    t.column :updated_at,     :datetime
    t.column :deleted_by,     :integer
    t.column :deleted_at,     :datetime
  end

  create_table :tags, force: true do |t|
    t.column :title,          :string
  end

  create_table :post_tags, force: true do |t|
    t.column :post_id,        :integer
    t.column :tag_id,         :integer
  end

  # Posts are created and updated by People or Bots
  create_table :poly_posts, :force => true do |t|
    t.column :title,          :string
    t.column :creator_id,     :integer
    t.column :creator_type,   :string
    t.column :created_on,     :datetime
    t.column :updater_id,     :integer
    t.column :updater_type,   :string
    t.column :updated_at,     :datetime
    t.column :deleter_id,     :integer
    t.column :deleter_type,   :string
    t.column :deleted_at,     :datetime
  end

  # Comments are created and updated by People or Bots
  create_table :poly_comments, :force => true do |t|
    t.column :poly_post_id,        :integer
    t.column :comment,        :string
    t.column :creator_id,     :integer
    t.column :creator_type,   :string
    t.column :created_on,     :datetime
    t.column :updater_id,     :integer
    t.column :updater_type,   :string
    t.column :updated_at,     :datetime
    t.column :deleter_id,     :integer
    t.column :deleter_type,   :string
    t.column :deleted_at,     :datetime
  end
end
