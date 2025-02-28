server "216.48.177.234",user: 'root', roles: [:web, :app, :db], primary: true

set :assets_roles, [:web, :app]

set :user, "root"
set :application, "dri"
set :repo_url, "git@github.com:aklavya28/dri.git"

# Default branch is :master
set :branch, "main"
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/#{fetch(:user)}/apps/#{fetch(:application)}"
set :rails_env, "production"
# set :default_env, { 'RAILS_ENV' => 'production' }
set :format, :pretty
set :log_level, :info

# Passenger (otherwise your user needs sudo rights on the server)
set :passenger_restart_with_touch, true

set :linked_files, %w{config/database.yml .env config/master.key}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

set :keep_releases, 3
set :keep_assets, 2

set :rvm_type, :user                     # Defaults to: :auto
set :rvm_ruby_version, "3.0.3"           # Defaults to: 'default'
set :rvm_roles, :all
set :rvm_custom_path, "/usr/local/rvm"

# set :ssh_options, {
#   user: "#{fetch(:user)}",
#   keys: %w(/home/rahul/.ssh/id_rsa),
#   forward_agent: true,
#   auth_methods: %w(publickey),
# }
# namespace :deploy do
#   before :starting, :clean_up_repo do
#     on roles(:all) do
#       execute :rm, 'sudo -rf /root/apps/dri/repo'
#     end
#   end
# end


# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
