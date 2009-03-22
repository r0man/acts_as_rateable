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
        def find_ratings_for(instance, options = { })
          Rating.find :all, options.reverse_merge(:conditions => { :rateable_id => instance.id, :rateable_type => rateable_type })
        end

        # Helper class method to lookup ratings for
        # the mixin rateable type written by a given user.
        # This method is NOT equivalent to Rating.find_ratings_for_user
        def find_ratings_by_user(user, options = { })
          Rating.find :all, options.reverse_merge(:conditions => { :user_id => user.id, :rateable_type => rateable_type })
        end

        # Helper class method to lookup rateable instances
        # with a given rating.
        def find_by_rating(rating, options = { })

          Rating.find(:all, options.reverse_merge(:conditions => { :rating => rating,  :rateable_type => rateable_type})).collect do |rating|
            rating.rateable
          end.uniq

        end

        def rateable_type
          ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
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
            Rating.delete_all rateable_conditions.merge(:user_id => user.id)
            reload
          end

        end

        def rate(rating, user = nil)
          delete_ratings_by_user(user)
          create_rating(rating, user)
        end

        # Returns the average rating of the rateable. The average
        # rating calculation is done by the database and gets cached
        # to the instance variable @acts_as_rateable_average_rating.
        #
        # ==== Parameters
        #
        # * +options+ - Use <tt>:force_reload => true</tt> to re-calculate the average rating.
        def rating(options = { })

          if @acts_as_rateable_average_rating.nil? or options[:force_reload]
            @acts_as_rateable_average_rating = Rating.send(:with_exclusive_scope) {
              Rating.find(:first, :select => "AVG(rating) AS average_rating", :conditions => rateable_conditions).average_rating.to_f
            }

          end

          @acts_as_rateable_average_rating

        end

        # Returns true if the rateable has been rated by the given
        # +user+, else false.
        #
        # ==== Parameters
        #
        # * +user+ - The user in question.
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
          ratings.build(:rating => rating, :user => user)
        end

        def create_rating(rating, user = nil)
          rating = build_rating(rating, user)
          rating.save!
          rating
        end

        def rateable_conditions
          {
            :rateable_id   => self.id,
            :rateable_type => self.class.rateable_type
          }
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
