require 'test_helper'

class ActsAsRateableTest < ActiveSupport::TestCase

  load_schema

  class Article < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
