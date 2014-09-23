set :application, "cloud.cim120.com.cn"
tag = ENV["TAG"] || nil
if !tag
    set :repository,  "svn://yubo@main-web/cim-public/trunk"
else
    set :repository,  "svn://yubo@main-web/cim-public/tags/#{tag}"
end

set :scm, :subversion
#set :scm_username, "yubo "
set :scm_password, "cim120.yb.qwe" 
set :use_sudo, false

set :deploy_to, "/data0/www/#{application}"
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :product,  "yubo@sub-web", "yubo@main-web"# Your HTTP server, Apache/etc
role :test, "yubo@test-web"

set :keep_releases, 50
# Default value for :linked_files is []
set :site_linked_files, %w{app/config/app.php app/config/cache.php app/config/database.php app/config/session.php}

# Default value for linked_dirs is []
set :site_linked_dirs, [["/data0/head_photos", "public/head_photos"]]


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
after "deploy:setup", "deploy:chmod_setup"
after "deploy:setup", "deploy:upload_config"

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
        puts "previous_release: "+previous_release if previous_release
        puts "current_path: "+current_path
        all_files = Dir.glob("site_config/**/*").select{|f| File.file?(f)}
        all_files.each{|f|
          target_dir = "#{deploy_to}/shared/#{f}"
          top.run("mkdir -p `dirname #{target_dir}`")
          top.upload(f, target_dir)
        }
    end

    desc "mkdir dir has a+w permission"
    task :chmod_setup do
      top.run("#{try_sudo} chmod -R a+w #{deploy_to}")
    end

    task :finalize_update, :except => { :no_release => true } do
      shells = []
      site_linked_files.each{|file|
        from = "#{deploy_to}/shared/site_config/#{file}"
        to = "#{current_release}/#{file}"
        shells << "rm -rf #{to} && ln -s #{from} #{to}"
      }
      site_linked_dirs.each{|dirs|
        (from, dir) = dirs
        dir = from if not dir
        from = "#{deploy_to}/shared/#{from}" if not from.start_with? "/"
        to = "#{current_release}/#{dir}"
        shells << "rm -rf #{to} && ln -s #{from} #{to}"
      }
      top.run(shells.join(" && ")) if shells.count > 0
    end
end
