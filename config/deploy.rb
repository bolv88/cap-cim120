set :application, "test-web"
tag = ENV["TAG"] || nil
if !tag
    set :repository,  "svn://yubo@main-web/cim-public/trunk"
else
    set :repository,  "svn://yubo@main-web/cim-public/tag/#{tag}"
end

set :scm, :subversion
#set :scm_username, "yubo "
set :scm_password, "cim120.yb.qwe" 
set :use_sudo, true

set :deploy_to, "/u"
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :app, "yubo@test-web", "yubo@sub-web", "yubo@main-web"# Your HTTP server, Apache/etc

set :keep_releases, 50
# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
after "deploy:setup", "deploy:chmod_setup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
namespace :deploy do
    task :upload_config do
        puts "previous_release: "+previous_release
        puts "current_path: "+current_path

        target_dir = "shared/site_config"
        top.run("mkdir -p #{target_dir}")
        top.upload("site_config", "shared/site_config")
    end

    desc "mkdir dir has a+w permission"
    task :chmod_setup do
        top.run("#{try_sudo} chmod -R a+w #{deploy_to}")
    end

    task :finalize_update, :except => { :no_release => true } do
        puts "previous_release: "+previous_release
        puts "current_release: "+current_release
        puts "current_path: "+current_path
    end
end
