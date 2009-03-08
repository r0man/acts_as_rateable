class ActsAsRateableGenerator < Rails::Generator::Base

  attr_reader :migration_name

  def manifest

    @migration_name = "CreateRatings"

    record do |m|
      m.migration_template 'acts_as_rateable_migration.rb.erb', File.join("db", "migrate"), { :migration_file_name => "create_ratings" }
    end

  end

end
