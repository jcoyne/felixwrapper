## These tasks get loaded into the host application when felixwrapper is required
require 'yaml'

namespace :felix do
  
  desc "Return the status of felix"
  task :status => :environment do
    running = Felixwrapper.is_felix_running?(FELIX_CONFIG)
    responding = Felixwrapper.is_felix_responding?(FELIX_CONFIG) unless !running
    if running and responding
        status = "Running: #{Felixwrapper.pid(FELIX_CONFIG)}"
    elsif running
        status = "Running: #{Felixwrapper.pid(FELIX_CONFIG)} ... but not yet responding"
    else
        status = "Not running"
    end
    puts status
  end
  
  desc "Start felix"
  task :start => :environment do
    Felixwrapper.start(FELIX_CONFIG)
    puts "felix started at PID #{Felixwrapper.pid(FELIX_CONFIG)}"
  end
  
  desc "stop felix"
  task :stop => :environment do
    Felixwrapper.stop(FELIX_CONFIG)
    puts "felix stopped"
  end
  
  desc "Restarts felix"
  task :restart => :environment do
    Felixwrapper.stop(FELIX_CONFIG)
    Felixwrapper.start(FELIX_CONFIG)
  end


  desc "Load the felix config"
  task :environment do
    unless defined? FELIX_CONFIG
      FELIX_CONFIG = Felixwrapper.load_config
    end
  end

  desc "Copies the default Matterhorn config for the bundled felix"
  task :config_matterhorn => [:environment] do
    FileList['felix_conf/*'].each do |f|
      cp_r("#{f}", 'felix/etc', :verbose => true)
    end
  end

  desc "Copies the default Matterhorn configs into the bundled felix"
  task :config do
    Rake::Task["felix:config_matterhorn"].invoke
  end
end

