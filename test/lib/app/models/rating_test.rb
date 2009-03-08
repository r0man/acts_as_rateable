require File.dirname(__FILE__) + '/../../../test_helper.rb'

class RatingTest < ActiveSupport::TestCase

  load_schema

  def setup

    @article = Article.create(:text => "Lorem ipsum dolor sit amet.")

    @alice = User.create(:name => "alice")
    @bob   = User.create(:name => "bob")

    @rating_alice = Rating.create(:rateable_type => Article.to_s, :rateable_id => @article.id, :user => @alice, :rating => 1)
    @rating_bob   = Rating.create(:rateable_type => Article.to_s, :rateable_id => @article.id, :user => @bob, :rating => 2)

  end

  test "belongs to user" do
    assert_equal @alice, @rating_alice.user
    assert_equal @bob, @rating_bob.user
  end

  test "belongs to rateable" do
    assert_equal @article, @rating_alice.rateable
    assert_equal @article, @rating_bob.rateable
  end

  test "rating" do
    assert_equal 1, @rating_alice.rating
    assert_equal 2, @rating_bob.rating
  end

  test "find ratings by user" do
    assert_equal [@rating_alice], Rating.find_ratings_by_user(@alice)
    assert_equal [@rating_bob], Rating.find_ratings_by_user(@bob)
  end

end
