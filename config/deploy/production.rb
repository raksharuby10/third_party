
server '3.110.224.88', user: 'ubuntu', roles: [:web, :app, :db], primary: true, ssh_options: { forward_agent: true }
set :rails_env, :production
set :rack_env,  :production
set :stage,     :production
set :branch,    :main
