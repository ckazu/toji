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

gem 'rails-i18n', '~> 4.0.0'
gem 'rails-config'
# gem 'configatron'
# gem 'settingslogic'
gem 'haml-rails'
gem 'less-rails'
gem 'underscore-rails'
gem 'underscore-string-rails'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails', branch: 'bootstrap3'

run_bundle

insert_into_file 'app/assets/javascripts/application.js', "//= require underscore\n", before: '//= require_tree .'
insert_into_file 'app/assets/javascripts/application.js', "//= require underscore.string\n", before: '//= require_tree .'
commit "Add libraly Gemfiles"

git rm: 'app/views/layouts/application.html.erb'
generate 'bootstrap:install less'
generate 'bootstrap:layout application fixed'
insert_into_file 'app/assets/stylesheets/bootstrap_and_overrides.css.less', "body { padding-top: 60px };\n", after: "// @linkColor: #ff0000;\n"
commit 'Introduce twitter-bootstrap'

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
  # ci, metrics
  gem 'coveralls', require: false
  gem 'rails_best_practices'
  gem 'brakeman'
  gem 'bullet'
  # gem 'exception-notification'
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

insert_into_file 'config/environments/development.rb', after: "TestApp::Application.configure do\n" do
<<-CONFIG
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.growl = false
    Bullet.rails_logger = true
  end
CONFIG
end

run_bundle
generate 'rspec:install'
run 'bundle exec guard init rspec'
commit "Add development Gemfiles"
