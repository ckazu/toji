def commit(message)
  git add: '.'
  git commit: "-m '#{message}'"
end

# first commit
file 'README.md', 'README'
git :init
git add: 'README.md'
git commit: "-m 'initial commit'"

# commit initial rails files
run "rm README.rdoc"

commit "rails new"

# Gemfiles
gem_group :development, :test do
  # rspec
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'ffaker'
  # auto run
  gem 'guard-rspec'
  gem 'spring'
  # ci
  gem 'coveralls', require: false
  # server
  gem 'puma'
  # debug
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

run 'bundle install'

generate 'rspec:install'

run 'bundle exec guard init rspec'

commit "add development Gemfiles"
