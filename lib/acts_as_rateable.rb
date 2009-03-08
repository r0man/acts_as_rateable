# ActsAsRateable
module Juixe
  module Acts #:nodoc:
    module Rateable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        def acts_as_rateable(definitions = { })

          include Juixe::Acts::Rateable::InstanceMethods
          extend Juixe::Acts::Rateable::SingletonMethods

          has_many :ratings, :as => :rateable, :dependent => definitions[:dependent] || :delete_all

          write_inheritable_attribute(:rating_definitions, Hash.new) if rating_definitions.nil?
          rating_definitions.update(definitions)

        end

        def rating_definitions
          read_inheritable_attribute(:rating_definitions)
        end

      end

      # This module contains class methods
      module SingletonMethods

        # Helper method to lookup for ratings for a given object.
        # This method is equivalent to obj.ratings
        def find_ratings_for(instance)
          Rating.find(:all, :conditions => { :rateable_id => instance.id, :rateable_type => rateable_type }, :order => "created_at DESC")
        end

        # Helper class method to lookup ratings for
        # the mixin rateable type written by a given user.
        # This method is NOT equivalent to Rating.find_ratings_for_user
        def find_ratings_by_user(user)
          Rating.find(:all, :conditions => { :user_id => user.id, :rateable_type => rateable_type }, :order => "created_at DESC")
        end

        # Helper class method to lookup rateable instances
        # with a given rating.
        def find_by_rating(rating)

          Rating.find(:all, :conditions => { :rating => rating,  :rateable_type => rateable_type}, :order => "created_at DESC").collect do |rating|
            rating.rateable
          end.uniq

        end

        def rateable_type
          # ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s # TODO: Why the direct descendant?
          self.to_s
        end

      end

      # This module contains instance methods
      module InstanceMethods

        def add_rating(rating)
          delete_ratings_by_user(rating.user)
          ratings << rating
        end

        def delete_ratings_by_user(user)

          if user
            Rating.delete_all(["rateable_type = ? AND rateable_id = ? AND user_id = ?", self.class.to_s, self.id, user.id])
            reload
          end

        end

        def rate(rating, user = nil)
          delete_ratings_by_user(user)
          create_rating(rating, user)
        end

        # Helper method that returns the average rating
        def rating
          average = 0.0
          ratings.each { |r|
            average = average + r.rating
          }
          if ratings.size != 0
            average = average / ratings.size
          end
          average
        end

        # Check to see if a user already rated this rateable
        def rated_by_user?(user)
          rtn = false
          if user
            self.ratings.each { |b|
              rtn = true if user.id == b.user_id
            }
          end
          rtn
        end

        protected

        def build_rating(rating, user = nil)
          validate_rating!(rating)
          ratings.create(:rating => rating, :user => user)
        end

        def create_rating(rating, user = nil)
          rating = build_rating(rating, user)
          rating.save
          rating
        end

        def validate_rating!(rating)

          if (range = self.class.rating_definitions[:range]) and !range.include?(rating.to_i)
            raise ArgumentError, "Rating not in range #{range}: #{rating}"
          end

        end

      end
    end
  end
end

%w(models).each do |dir|

  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path

  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)

end

ActiveRecord::Base.send :include, Juixe::Acts::Rateable
