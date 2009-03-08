require File.dirname(__FILE__) + '/test_helper.rb'

class RatingTest < Test::Unit::TestCase

  load_schema

  def setup

    @article = Article.create(:text => "Lorem ipsum dolor sit amet.")

    @alice = User.create(:name => "alice")
    @bob   = User.create(:name => "bob")

    @rating_alice = Rating.create(:rateable_type => Article.to_s, :rateable_id => @article.id, :user => @alice, :rating => 1)
    @rating_bob   = Rating.create(:rateable_type => Article.to_s, :rateable_id => @article.id, :user => @bob, :rating => 2)

  end

  def test_belongs_to_user
    assert_equal @alice, @rating_alice.user
    assert_equal @bob, @rating_bob.user
  end

  def test_belongs_to_rateable
    assert_equal @article, @rating_alice.rateable
    assert_equal @article, @rating_bob.rateable
  end

  def test_rating
    assert_equal 1, @rating_alice.rating
    assert_equal 2, @rating_bob.rating
  end

  def test_find_ratings_by_user
    assert_equal [@rating_alice], Rating.find_ratings_by_user(@alice)
    assert_equal [@rating_bob], Rating.find_ratings_by_user(@bob)
  end

end
