source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Haml for HTML
gem 'haml-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'

# Use Bourbon for styles
gem 'bourbon'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
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
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

LOCAL_GEMS_PATHS = ['..', '~/Projects']
gem_location = lambda do |project|
	local_paths = LOCAL_GEMS_PATHS.map { |prefix| "#{prefix}/#{project}" }
	if File.exist?(File.expand_path(local_paths[0]))
		{ path: local_paths[0] }
	elsif File.exist?(File.expand_path(local_paths[1]))
		{ path: local_paths[1] }
	else
		{ github: "gioele/#{project}" }
	end
end

# Sanskrit <-> Latin transliteration
gem 't13n', gem_location['t13n']

# eXist is contacted via XPathQuery + rest-client
gem 'xpathquery', gem_location['xpathquery']
gem 'rest-client'

# Nokogiri as XML processor
gem 'nokogiri'

# High voltage for mostly-static pages like the homepage
gem 'high_voltage', '~> 2.2.1'

# markerb (and kramdown) to parse static pages written in Markdown + ERB
gem 'markerb'
gem 'kramdown'

group :development do
	# Runtime developer console
	gem 'pry'
	gem 'pry-byebug'

	# Access an IRB console on exception pages or by using <%= console %> in views
	gem 'web-console', '~> 2.0'

	# RailsAdmin provides an easy-to-use interface for your data . https://github.com/sferik/rails_admin
	#gem 'rails_admin'

	# Better error page for Rails and other Rack apps. https://github.com/charliesome/better_errors
	gem 'better_errors'
	gem 'binding_of_caller'

	# Log support for HTTP requests (i.e. XML DB requests)
	gem 'http_logger'

	# Profile performance using ruby-prof and rack-mini-profiler
	gem 'ruby-prof'
	gem 'rack-mini-profiler', require: false
end


# Licensed under the ISC licence, see LICENCE.ISC for details
