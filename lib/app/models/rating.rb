class Rating < ActiveRecord::Base

  belongs_to :rateable, :polymorphic => true
  belongs_to :user

  default_scope :order => 'created_at DESC'

  class << self

    def find_ratings_by_user(user)
      find :all, :conditions => { :user_id => user.id }
    end

  end

end

