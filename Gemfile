source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"
# gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem "devise"
gem "devise-jwt"
gem 'jsonapi-serializer'
gem "plutus"
gem 'friendly_id', '~> 5.5.0'
gem 'json', '~> 2.7', '>= 2.7.1'
# gem 'will_paginate', '~> 3.3'
# gem 'will_paginate', '~> 4.0'
# gem 'kaminari'
gem 'pagy'
gem 'pager_api'

group :development do
  gem "capistrano", "~> 3.17", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-rvm"
  gem "capistrano-passenger", require: false
 end
 gem "passenger"
 gem "dotenv-rails"
 gem 'sprockets-rails'
#  gem 'switchman'
