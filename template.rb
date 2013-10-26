def commit(message)
  git add: '.'
  git commit: "-m '#{message}'"
end

def remove_comment_lines(file)
  gsub_file file, /^( )*#\s.*$/, ''
  gsub_file file, /(\n)+/m, "\n"
end

# first commit
file 'README.md', "# #{app_name}"
git :init
git add: 'README.md'
git commit: "-m 'initial commit'"

# commit initial rails files
run "rm README.rdoc"
%w|Gemfile config/routes.rb|.each do |file|
  remove_comment_lines file
end

commit "rails new #{app_name}"

gsub_file 'Gemfile', /^group :doc do.*end$\n/m, ''
gsub_file 'Gemfile', /^.*sass-rails.*\n/, ''

gem 'rails-i18n', '~> 4.0.0.pre'
gem 'haml-rails'
gem 'less-rails'
gem 'underscore-rails'
gem 'underscore-string-rails'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails', branch: 'bootstrap3'

run_bundle

generate 'bootstrap:install less'
insert_into_file 'app/assets/javascripts/application.js', "//= require underscore\n", before: '//= require_tree .'
insert_into_file 'app/assets/javascripts/application.js', "//= require underscore.string\n", before: '//= require_tree .'

remove_file 'app/views/layout/application.html.erb'
# [ToDo] replace above template
create_file 'app/views/layout/application.html.haml' do
<<-TEMPLATE
!!! html
%head
  %title #{app_name}
  = stylesheet_link_tag 'application', media: :all, 'data-turbolinks-track' => true
  = javascript_include_tag 'application', 'data-turbolinks-track' => true
  = csrf_meta_tags
%body
  = yield
TEMPLATE
end

commit "add libraly Gemfiles"

# Gemfiles
gem_group :development, :test do
  # rspec
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'timecop'
  gem 'database_rewinder'
  # auto run
  gem 'guard-rspec'
  gem 'spring'
  # ci
  gem 'coveralls', require: false
  # server
  gem 'puma'
  gem 'quiet_assets'
  # misc
  gem 'tapp'
  gem 'awesome_print'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

run_bundle
generate 'rspec:install'
run 'bundle exec guard init rspec'
commit "add development Gemfiles"
