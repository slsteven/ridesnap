source 'https://rubygems.org'

ruby '2.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.4'

# Use pg as the database
gem 'pg'

# Use SCSS and bootstrap for styles
gem 'bootstrap-sass', '~> 3.2.0'
gem 'sass-rails', '>= 3.2'
# Pagination
gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'
# Autoprefixer adds the appropriate CSS browser prefixes to everything!
gem 'autoprefixer-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# Javascript templating engine...
# gem 'react-rails', '~> 1.0.0.pre', github: 'reactjs/react-rails'
# Use HAML for the views
gem 'haml'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
# State Machine
gem 'aasm'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# get your Rails variables in your js
# gem 'gon'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use thin as the app server
gem 'thin' # this can go into the dev group if using passenger / nginx in production

group :development do
  # Use Capistrano for deployment
  # gem 'capistrano',  '~> 3.1'
  # gem 'capistrano-rails', '~> 1.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'pry-rails'
  # gem 'debugger'
end

group :production do
  # necessary for heroku
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
end

gem 'httparty' # used for making zipcode requests to google to find city/state
gem 'nokogiri' # scraper... but only using internally to build inline SVGs
gem 'meta-tags'

gem 'rails_config'

