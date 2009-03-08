class Rating < ActiveRecord::Base

  belongs_to :rateable, :polymorphic => true
  belongs_to :user

  class << self

    def find_ratings_by_user(user)
      find(:all, :conditions => { :user_id => user.id }, :order => "created_at DESC")
    end

  end

end

