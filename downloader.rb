require 'double_bag_ftps'
require 'net/ftp/list' 
require 'time'
require 'relparser'
require 'yaml'
require 'fileutils'

class Downloader

  def initialize
    @conf = YAML.load_file("config.yaml")
  end

  def run
    puts Time.now.to_s
    connect
    check_dirs
    disconnect
  end

  private

  def connect
    @ftps = DoubleBagFTPS.new
    @ftps.passive=true
    @ftps.ssl_context = DoubleBagFTPS.create_ssl_context(:verify_mode => OpenSSL::SSL::VERIFY_NONE)
    @ftps.connect(@conf["host"]["dns"], @conf["host"]["port"])
    @ftps.login(@conf["host"]["username"], @conf["host"]["pass"])
  end

  def check_dirs
    @conf["dirs"].each {|e| check_dir e}
  end

  def check_dir settings
    @ftps.chdir(settings["path"])
    c = @ftps.list
    now = Time.now
    c.each do |l|
      e = Net::FTP::List.parse(l)

      next unless e.dir?
      age = ((now-e.mtime) / 3600).round

      if(age < 4) then
        begin
          r = RelParser.parse e.basename	
          if(settings["want"].any?{ |s| s.casecmp(r.name)==0 }) then
            @ftps.chdir(e.basename)
            files = @ftps.list
            if(files.any?{|f| Net::FTP::List.parse(f).basename.include?("COMPLETE")}) then
              puts "#{e.basename} is complete!"
              download(settings["save_to"],e.basename, files)
            end
            @ftps.chdir("..")
          end
        rescue => ex
	  p ex
	  p ex.backtrace
        end
      end
    end
  end

  def download(local_path, name, files)
    lp = local_path + "/" + name
    FileUtils.mkpath lp unless File.directory?(lp)

    files.each do |f|
      e = Net::FTP::List.parse(f)
      next unless e.file?
      if !File.exists?(lp+"/"+e.basename) then
        puts "download #{e.basename}"
        @ftps.getbinaryfile(e.basename,lp+"/"+e.basename )
      end 
    end

  end

  def disconnect
    @ftps.close
  end
end
