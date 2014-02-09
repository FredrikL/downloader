require 'rufus-scheduler'
require_relative 'downloader'

scheduler = Rufus::Scheduler.new

scheduler.every '1h' do
  d = Downloader.new
  d.run
end

scheduler.join