ActiveRecord::Schema.define(:version => 0) do

  create_table :users, :force => true do |t|
    t.string :name
  end

  create_table :articles, :force => true do |t|
    t.string :content
  end

  create_table :ratings, :force => true do |t|
    t.string  :rateable_type, :null => false
    t.integer :rateable_id,   :null => false
    t.integer :user_id,       :null => false
    t.integer :rating,        :null => false
  end

end
