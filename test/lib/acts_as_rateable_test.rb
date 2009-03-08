require File.dirname(__FILE__) + '/../test_helper.rb'

class ActsAsRateableTest < ActiveSupport::TestCase

  load_schema

  def setup
    Rating.delete_all
    @article = Article.create(:text => "Lorem ipsum dolor sit amet.")
    @alice, @bob = User.create(:name => "alice"), User.create(:name => "bob")
  end

  test "rateable type" do
    assert_equal "Article", Article.rateable_type
  end

  test "add rating from one user" do

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 1, :user => @alice)
    assert_equal 1, @article.rating

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 2, :user => @alice)
    assert_equal 2, @article.rating

  end

  test "rate with one user" do

    @article.rate(1, @alice)
    assert_equal 1.0, @article.rating

    @article.rate(2, @alice)
    assert_equal 2, @article.rating

  end

  test "add ratings from multiple users" do

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 1, :user => @alice)
    assert_equal 1, @article.rating

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 2, :user => @bob)
    assert_equal 1.5, @article.rating

  end

  test "rate with multiple users" do

    @article.rate(1, @alice)
    assert_equal 1.0, @article.rating

    @article.rate(2, @alice)
    assert_equal 2, @article.rating

    @article.rate(4, @bob)
    assert_equal 3, @article.rating

  end

  test "rate without tracking the user" do

    @article.rate(1)
    assert_equal 1.0, @article.rating

    @article.rate(2)
    assert_equal 1.5, @article.rating

  end

  test "add ratings not tracking the user" do

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 1)
    assert_equal 1, @article.rating

    @article.add_rating Rating.new(:rateable_type => @article.class.to_s, :rateable_id => @article.id, :rating => 2)
    assert_equal 1.5, @article.rating

  end

  test "rated by user" do
    assert !@article.rated_by_user?(@alice)
    @article.rate(2, @alice)
    assert @article.rated_by_user?(@alice)
  end

  test "find ratings for the given rateable" do

    other_article = Article.create(:text => "Lorem ipsum dolor sit amet.")
    other_article.rate(4, @alice)

    assert_equal [], Article.find_ratings_for(@article)

    rating_alice = @article.rate(2, @alice)
    assert_equal [rating_alice], Article.find_ratings_for(@article)

    rating_bob = @article.rate(3, @bob)
    assert_equal [rating_alice, rating_bob], Article.find_ratings_for(@article)

  end

  test "find ratings by user" do

    assert_equal [], Article.find_ratings_by_user(@alice)

    rating_alice = @article.rate(2, @alice)
    assert_equal [rating_alice], Article.find_ratings_by_user(@alice)

    rating_bob = @article.rate(3, @bob)
    assert_equal [rating_bob], Article.find_ratings_by_user(@bob)

  end

  test "find by rating" do

    assert_equal [], Article.find_by_rating(1)

    rating_alice = @article.rate(1, @alice)
    assert_equal 1, @article.rating
    assert_equal [@article], Article.find_by_rating(1)

    rating_bob = @article.rate(2, @bob)
    assert_equal 1.5, @article.rating
    assert_equal [@article], Article.find_by_rating(2)

  end

  test "underrating" do
    assert_raise ArgumentError do
      @article.rate(@article.class.rating_definitions[:range].min - 1)
    end
  end

  test "overrating" do
    assert_raise ArgumentError do
      @article.rate(@article.class.rating_definitions[:range].max + 1)
    end
  end

end
