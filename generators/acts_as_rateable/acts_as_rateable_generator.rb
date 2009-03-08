class ActsAsRateableGenerator < Rails::Generator::Base

  def manifest

    @migration_name = "CreateRatings"

    record do |m|
      m.migration_template 'acts_as_rateable_migration.rb', File.join("db", "migrate"), { :migration_file_name => "create_ratings" }
    end

  end

end
