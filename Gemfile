source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# necessary for rails
gem "railties", ">= 0"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# jquery turbolinks change the way turbolink interacts with other frameworks, is to prevent conflicts
# gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# foundation layout framework
# current version of the foundation gem doesn't work with rails / turbolinks
# gem 'foundation-rails'

# ruleby rule engine
gem 'ruleby'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do

  # gem for displaying better erros
  gem 'better_errors', '1.0.1'

  # gem for displaying additional information for better errors
  gem 'binding_of_caller', '0.7.2'

  # gem for use in combination with rails panel in chrome
  gem 'meta_request', '0.2.8'

  # database for developing
  gem 'sqlite3'

end

group :production do

  # Use postgresql as the database for Active Record
  gem 'pg'

  # heroku integration gem
  gem 'rails_12factor'

end

# gem for creating fake database entries
# included in all environments, because when used in rake task Heroku crashes because can't find Faker
gem 'faker', '1.2.0'

# necessary for Heroku
ruby '2.0.0'