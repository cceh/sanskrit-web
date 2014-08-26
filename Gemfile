source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Haml for HTML
gem 'haml-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

group :doc do
	# bundle exec rake doc:rails generates the API under doc/api.
	#gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use puma as the app server
gem 'puma'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

LOCAL_GEMS_PATH = '~/Projects'
gem_location = lambda do |project|
	local_path = "#{LOCAL_GEMS_PATH}/#{project}"
	if File.exist?(File.expand_path(local_path))
		{ path: local_path }
	else
		{ github: "gioele/#{project}" }
	end
end

# Sanskrit <-> Latin transliteration
gem 't13n', gem_location['t13n']

# eXist is contacted via XPathQuery + rest_client
gem 'xpathquery', gem_location['xpathquery']
gem 'rest_client'

# Nokogiri as XML processor
gem 'nokogiri'

# High voltage for mostly-static pages like the homepage
gem 'high_voltage', '~> 2.2.1'

group :development do
	# Runtime developer console
	gem 'pry'

	# RailsAdmin provides an easy-to-use interface for your data . https://github.com/sferik/rails_admin
	#gem 'rails_admin'

	# Better error page for Rails and other Rack apps. https://github.com/charliesome/better_errors
	gem 'better_errors'
	gem 'binding_of_caller'
end

