ActiveRecord::Schema.define(:version => 0) do

  create_table :users, :force => true do |t|
    t.string :name
  end

  create_table :articles, :force => true do |t|
    t.string :text
  end

  create_table :ratings, :force => true do |t|
    t.string   :rateable_type
    t.integer  :rateable_id
    t.integer  :user_id
    t.integer  :rating
    t.datetime :created_at
  end

end
