Acts As Rateable
================

This plugin allows rating on models. It's a fork from the original
plugin developed by Juixe Software to work with newer versions of
Rails. The API has changed slightly. See the credits section for a
link to the original code.

Installation
------------

Install the plugin:

        ./script/plugin install git://github.com/r0man/acts_as_rateable.git

Usage
-----

Create a migration:

       ./script/generate acts_as_rateable

Make your model rateable:

      class Article < ActiveRecord::Base
        acts_as_rateable :range => (1..5)
      end

      article = Article.create(:text => "Lorem ipsum dolor sit amet.")
      alice, bob = User.create(:name => "alice"), User.create(:name => "bob")

      article.rate(1, alice)
      article.rating # => 1

      article.rate(2, bob)
      article.rating # => 1 (cached)
      article.rating(:force_reload => true) # => 1.5

Look at the tests to see more examples...

Credits
-------

Originally written by Juixe Software.

- <http://www.juixe.com/techknow/index.php/2006/07/05/acts-as-rateable-plugin>

---

Copyright (c) 2009 Roman Scherer, released under the MIT license
