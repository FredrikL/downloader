task :default => [:run]

task :run do
	ruby "sched.rb"
end

task :download do
  require_relative 'downloader'
  d = Downloader.new
  d.run
end