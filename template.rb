# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

JAVASCRIPT_LIBS = [
  'core-js@3',
  'expose-loader',
  'jquery',
  'popper.js',
  'bootstrap',
  'data-confirm-modal',
  'local-time',
  'i18n-js',
  'lodash',
]

JAVASCRIPT_DEV_LIBS = [
  'babel-eslint',
  'babel-plugin-import',
  'babel-plugin-module-resolver',
  'eslint',
  'eslint-config-airbnb',
  'eslint-config-prettier',
  'eslint-config-react-app',
  'eslint-find-rules',
  'eslint-import-resolver-alias',
  'eslint-import-resolver-typescript',
  'eslint-plugin-flowtype',
  'eslint-plugin-import',
  'eslint-plugin-jsx-a11y',
  's4san/eslint-plugin-lint-erb',
  'eslint-plugin-react',
  'eslint-plugin-react-hooks',
  'husky',
  'lint-staged',
  'npm-run-all',
  'postcss-flexbugs-fixes',
  'postcss-import',
  'postcss-preset-env',
  'prettier',
  'prettier-quick',
  'pretty-quick',
  'stylelint',
  'stylelint-config-prettier',
  'stylelint-config-standard',
  'stylelint-prettier',
  'webpack-dev-server',
]

COPY_FILES = [
  'Procfile',
  'Procfile.dev',
  'Guardfile',
  '.foreman',
  '.pryrc',
  '.rubocop.yml',
  '.rubocop_shopify.yml',
  '.reek.yml',
  '.editorconfig',
  '.gitignore',
  '.prettierignore',
  '.eslintignore',
  '.eslintrc.js',
  'postcss.config.js',
  'prettier.config.js',
  'stylelint.config.js',
  'babel.config.js',
]

REMOVE_FILES = [
  'config/locales/devise.en.yml',
  'config/locales/simple_form.en.yml',
]

DEVELOPMENT_DATABASE_URL = "postgres://postgres:@localhost/#{app_name}_development"
TEST_DATABASE_URL = "postgres://postgres:@localhost/#{app_name}_test"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__.match? %r{\Ahttps?://}
    require 'tmpdir'
    tempdir = Dir.mktmpdir 'jumpstart-'
    source_paths.unshift tempdir
    at_exit { FileUtils.remove_entry tempdir }
    git(clone: [
      '--quiet',
      'https://github.com/cj/jumpstart.git',
      tempdir,
    ].map(&:shellescape).join(' '))

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift File.dirname(__FILE__)
  end
end

def rails_version
  @rails_version ||= Gem::Version.new Rails::VERSION::STRING
end

def rails_5?
  Gem::Requirement.new('>= 5.2.0', '< 6.0.0.beta1').satisfied_by? rails_version
end

def rails_6?
  Gem::Requirement.new('>= 6.0.0.beta1', '< 7').satisfied_by? rails_version
end

def add_gems
  inject_into_file 'config/application.rb', after: "Bundler.require(*Rails.groups)\n" do
    <<~RUBY

      Dotenv::Railtie.load unless Rails.env.production?
    RUBY
  end

  inject_into_file 'Gemfile', after: /gem 'bootsnap'.*\n/ do
    <<~RUBY
      gem "pundit"
      gem 'rolify', github: 'cj/rolify', branch: 'patch/rails6-migration-support'
      gem 'zeitwerk', '~> 1.4', '>= 1.4.2'
      gem 'administrate', github: 'excid3/administrate', branch: 'zeitwerk'
      gem 'bootstrap', '~> 4.3', '>= 4.3.1'
      gem 'devise', '~> 4.6', '>= 4.6.1'
      gem 'devise-bootstrapped', github: 'excid3/devise-bootstrapped', branch: 'bootstrap4'
      gem 'devise_masquerade', '~> 0.6.2'
      gem 'font-awesome-sass', '~> 5.6', '>= 5.6.1'
      gem 'friendly_id', '~> 5.2', '>= 5.2.5'
      gem 'gravatar_image_tag', github: 'mdeering/gravatar_image_tag'
      gem 'mini_magick', '~> 4.9', '>= 4.9.2'
      gem 'name_of_person', '~> 1.1'
      gem 'omniauth-facebook', '~> 5.0'
      gem 'omniauth-github', '~> 1.3'
      gem 'omniauth-twitter', '~> 1.4'
      gem 'sidekiq', '~> 5.2', '>= 5.2.5'
      gem 'sitemap_generator', '~> 6.0', '>= 6.0.1'
      gem 'whenever', require: false
      gem "bootstrap_form", ">= 4.2.0"
      gem 'i18n-js'
      gem 'goldiloader'
      # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
      gem 'rack-cors'
      gem 'activerecord-import'
      gem 'simple_form'
    RUBY
  end
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do
    <<-RUBY
  gem 'dotenv-rails'
RUBY
  end

  inject_into_file 'Gemfile', after: "group :development do\n" do
    <<-RUBY
  gem 'guard'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'guard-rails', github: 'atd/guard-rails', require: false
  gem 'guard-process', require: false
  gem 'guard-bundler', require: false
  gem 'rack-livereload'
  gem "pry-remote"
  gem 'awesome_rails_console'
  gem 'hirb'
  gem 'hirb-unicode-steakknife', require: 'hirb-unicode'
  gem 'pry-stack_explorer'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'bullet', github: 'flyerhzm/bullet'
  gem 'lol_dba'
  gem 'rubocop'
  gem 'reek'
  gem 'rufo'
RUBY
  end

  if rails_5?
    gsub_file('Gemfile', /gem 'sqlite3'/, "gem 'sqlite3', '~> 1.3.0'")
    gem 'webpacker', '~> 4.0.1'
  end
end

def set_application_name
  # Add Application Name to Config
  if rails_5?
    environment 'config.application_name = Rails.application.class.parent_name'
  else
    environment 'config.application_name = Rails.application.class.module_parent_name'
  end

  # Announce the user where he can change the application name in the future.
  puts 'You can change application name inside: ./config/application.rb'
end

def add_simple_form
  # Install Devise
  generate 'simple_form:install --bootstrap --skip'

  simple_form_file = 'config/initializers/simple_form.rb'

  gsub_file(simple_form_file, /explicit_label/, '_explicit_label')
  gsub_file(simple_form_file, /browser_validations = false/, 'browser_validations = true')
  gsub_file(
    'config/initializers/simple_form_bootstrap.rb',
    /config.error_method = :to_sentence/,
    'config.error_method = :first',
  )
end

def add_users
  # Install Devise
  generate 'devise:install --skip'

  # Configure Devise
  environment(
    "config.action_mailer.default_url_options = { host: '0.0.0.0', port: 1025 }",
    env: 'development',
  )
  route "root to: 'home#index'"

  # Devise notices are installed via Bootstrap
  generate 'devise:views:bootstrapped'

  # Create Devise User
  generate(:devise, 'User',
    'first_name',
    'last_name',
    'announcements_last_read_at:datetime',
    'admin:boolean',)

  # Set admin default to false
  in_root do
    migration = Dir.glob('db/migrate/*').max_by { |file| File.mtime file }
    gsub_file migration, /:admin/, ':admin, default: false'
  end

  gsub_file('config/initializers/devise.rb',
    /config.http_authenticatable_on_xhr.+/,
    'config.http_authenticatable_on_xhr = false',)

  if Gem::Requirement.new('> 5.2').satisfied_by? rails_version
    gsub_file('config/initializers/devise.rb',
      /  # config.secret_key = .+/,
      '  config.secret_key = Rails.application.credentials.secret_key_base',)
  end
end

def add_webpack
  # Rails 6+ comes with webpacker by default, so we can skip this step
  if rails_5?
    # Our application layout already includes the javascript_pack_tag,
    # so we don't need to inject it
    rails_command 'webpacker:install'
  end

  add_webpacker_libs
  add_javascript
end

def add_javascript
  run "yarn add #{JAVASCRIPT_LIBS.join ' '}"
  run "yarn add --dev #{JAVASCRIPT_DEV_LIBS.join ' '}"

  if rails_5?
    run 'yarn add turbolinks @rails/actioncable@pre @rails/actiontext@pre @rails/activestorage@pre @rails/ujs@pre'
  end

  content = <<~JS
    const webpack = require('webpack')
    environment.plugins.append('Provide', new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Rails: '@rails/ujs'
    }))
  JS

  insert_into_file 'config/webpack/environment.js', content + "\n", before: 'module.exports = environment'

  gsub_file 'package.json', /"version".*/, ''

  insert_into_file 'package.json', after: ' "private": true,' do
    <<-TEXT
  "version": "0.0.1",
  "scripts": {
    "prettier": "pretty-quick --staged",
    "lint:rubocop": "bundle exec rubocop -a --format simple",
    "lint:reek": "bundle exec reek",
    "lint:ruby": "run-p lint:rubocop lint:reek",
    "lint:ts": "tslint -c tslint.json 'src/**/*.{ts,tsx}'",
    "lint:js": "eslint --ignore-path .eslintignore . --fix",
    "lint:css": "stylelint 'src/**/*.{less,scss,css}' --fix",
    "lint": "run-p lint:css lint:js & yarn lint:ruby"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "yarn run lint:js",
      "git add"
    ],
    "*.{ts,tsx}": [
      "yarn run lint:ts",
      "git add"
    ],
    "*.{css,scss}": [
      "yarn run lint:css",
      "git add"
    ],
    "*": [
      "npm run prettier",
      "git add"
    ]
  },
    TEXT
  end

  eslint_fix_files = ['config/webpack/environment.js']

  eslint_fix_files.each do |file_name|
    prepend_to_file file_name, "/* eslint-disable import/no-extraneous-dependencies, func-names, import/order */\n\n"
  end
end

def copy_templates
  remove_file 'app/assets/stylesheets/application.css'

  COPY_FILES.each { |file| copy_file file, force: true }

  directory 'app', force: true
  directory 'config', force: true
  directory 'lib', force: true
  directory 'db', force: true

  route "get '/terms', to: 'home#terms'"
  route "get '/privacy', to: 'home#privacy'"
end

def add_sidekiq
  environment 'config.active_job.queue_adapter = :sidekiq'

  insert_into_file('config/routes.rb',
    "require 'sidekiq/web'\n\n",
    before: 'Rails.application.routes.draw do',)

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file 'config/routes.rb', "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_announcements
  generate 'model Announcement published_at:datetime announcement_type name description:text'
  route 'resources :announcements, only: [:index]'
end

def add_notifications
  generate("model Notification recipient_id:bigint actor_id:bigint read_at:datetime \
           action:string notifiable_id:bigint notifiable_type:string")
  route 'resources :notifications, only: [:index]'
end

def add_administrate
  generate 'administrate:install'

  gsub_file('app/dashboards/announcement_dashboard.rb',
    /announcement_type: Field::String/,
    'announcement_type: Field::Select.with_options(collection: Announcement::TYPES)',)

  gsub_file('app/dashboards/user_dashboard.rb',
    /email: Field::String/,
    "email: Field::String,\n    password: Field::String.with_options(searchable: false)",)

  gsub_file('app/dashboards/user_dashboard.rb',
    /FORM_ATTRIBUTES = \[/,
    "FORM_ATTRIBUTES = [\n    :password,",)

  gsub_file('app/controllers/admin/application_controller.rb',
    /# TODO Add authentication logic here\./,
    "redirect_to '/', alert: 'Not authorized.' unless user_signed_in? && current_user.admin?",)

  environment do
    <<-RUBY
    # Expose our application's helpers to Administrate
    config.to_prepare do
      Administrate::ApplicationController.helper #{app_name.camelize}::Application.helpers
    end
  RUBY
  end
end

def add_multiple_authentication
  insert_into_file 'config/routes.rb', after: '  devise_for :users' do
    <<-RUBY
  , controllers: {
      omniauth_callbacks: "users/omniauth_callbacks",
      sessions: 'users/sessions',
      registrations: 'users/registrations',
  }
    RUBY
  end

  generate("model Service user:references provider uid access_token access_token_secret \
           refresh_token expires_at:datetime auth:text --skip")

  template = <<-RUBY
  env_creds = Rails.application.credentials.omniauth_provider

  %w{ facebook twitter github }.each do |provider|
    next unless env_creds

    options = env_creds[provider]

    if options
      config.omniauth provider, options[:app_id], options[:app_secret], options.fetch(:options, {})
    end
  end
RUBY

  insert_into_file('config/initializers/devise.rb', '  ' + template + "\n\n",
    before: '  # ==> Warden configuration',)

  uncomment_lines('config/initializers/devise.rb', /config.navigational_formats/)

  uncomment_lines('config/initializers/devise.rb', /config.http_authenticatable_on_xhr/)
end

def add_whenever
  run 'wheneverize .'
end

def add_friendly_id
  generate 'friendly_id'

  insert_into_file(
    Dir['db/migrate/**/*friendly_id_slugs.rb'].first,
    '[5.2]',
    after: 'ActiveRecord::Migration',
  )
end

def add_sitemap
  rails_command 'sitemap:install'
end

def add_environments
  environment("
  # Curerntly there is a bug with Zeitwerk
  config.autoloader = :classic
  ", env: 'development',)

  environment("
  # Add Rack::LiveReload to the bottom of the middleware stack with the default options:
  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload
  ", env: 'development',)

  create_file '.env' do
    <<~ENV
      BOT_ID=807
      BOT_NAME=System Bot
      BOT_EMAIL=system.bot@localhost
      RAILS_CORS_ORIGINS=localhost:5000,0.0.0.0:5000
      DEVELOPMENT_DATABASE_URL=#{DEVELOPMENT_DATABASE_URL}
      TEST_DATABASE_URL=#{TEST_DATABASE_URL}
      BUNDLE_GEMS__GRAPHQL__PRO=
    ENV
  end
end

def add_webpacker_libs
  rails_command 'webpacker:install:stimulus'
  rails_command 'webpacker:install:erb'
end

def update_database_yml
  database_yml_file = 'config/database.yml'

  comment_lines(database_yml_file, /(database|username|password):\s/)

  insert_into_file(
    database_yml_file,
    "  url: <%= ENV['DEVELOPMENT_DATABASE_URL'] %>",
    after: "# database: #{app_name}_development\n",
  )

  insert_into_file(
    database_yml_file,
    "  url: <%= ENV['TEST_DATABASE_URL'] %>",
    after: "# database: #{app_name}_test\n",
  )
end

def cleanup
  remove_file 'README'
end

def add_rolify
  generate 'rolify Role User'
end

def add_pundit
  generate 'pundit:install'
end

def set_default_columns
  Dir['db/migrate/*.rb'].each do |migration_file|
    gsub_file migration_file, /(t\.timestamps null: false|t\.timestamps|t\.datetime :created_at)/, 't.default_columns'
  end
end

# Main setup
add_template_repository_to_source_path

add_gems

after_bundle do
  set_application_name

  add_environments
  add_users
  add_webpack
  add_announcements
  add_notifications
  add_sidekiq
  add_friendly_id
  add_pundit

  copy_templates

  add_simple_form
  add_multiple_authentication
  add_whenever
  add_sitemap
  update_database_yml

  set_default_columns

  # Migrate
  rails_command 'db:create'
  rails_command 'db:migrate'

  add_rolify

  rails_command 'db:migrate'

  # Migrations must be done before this
  add_administrate

  cleanup

  # Autofix any Rubocop errors
  run 'yarn lint'

  # Commit everything to git
  git :init
  git add: '.'
  git commit: %{ -m 'Initial commit' }

  say
  say 'Jumpstart app successfully created!', :blue
  say
  say 'To get started with your new app:', :green
  say "cd #{app_name} - Switch to your new app's directory."
  say 'foreman start - Run Rails, sidekiq, and webpack-dev-server.'
end
