require 'fileutils'

module FckeditorFileUtils
  FCKEDITOR_INSTALL_DIRECTORY = File.join(RAILS_ROOT, '/public/javascripts/fckeditor/')

  def FckeditorFileUtils.recursive_copy(options)
    source = options[:source]
    dest = options[:dest]
    logging = options[:logging].nil? ? true : options[:logging]

    Dir.foreach(source) do |entry|
      next if entry =~ /^\./
      if File.directory?(File.join(source, entry))
        unless File.exist?(File.join(dest, entry))
          if logging
            puts "Creating directory #{entry}..."
          end
          FileUtils.mkdir File.join(dest, entry)#, :noop => true#, :verbose => true
        end
        recursive_copy(:source => File.join(source, entry),
                       :dest => File.join(dest, entry),
                       :logging => logging)
      else
        if logging
          puts "  Installing file #{entry}..."
        end
        FileUtils.cp File.join(source, entry), File.join(dest, entry)#, :noop => true#, :verbose => true
      end
    end
  end

  def FckeditorFileUtils.backup_existing
    source = File.join(RAILS_ROOT,'/public/javascripts/fckeditor')
    dest = File.join(RAILS_ROOT,'/public/javascripts/fckeditor_bck')

    FileUtils.rm_r(dest) if File.exists? dest
    FileUtils.mv source, dest
  end

  def FckeditorFileUtils.create_uploads_directory
    uploads = File.join(RAILS_ROOT, '/public/uploads')
    FileUtils.mkdir(uploads) unless File.exist?(uploads)
  end

  def FckeditorFileUtils.install(log)
    directory = File.join(RAILS_ROOT, '/vendor/extensions/fckeditor/')
    source = File.join(directory,'/public/javascripts/fckeditor/')
    FileUtils.mkdir(FCKEDITOR_INSTALL_DIRECTORY)
    # recursively copy all our files over
    recursive_copy(:source => source, :dest => FCKEDITOR_INSTALL_DIRECTORY, :logging => log)
    # create the upload directories
    create_uploads_directory
  end

  def FckeditorFileUtils.destroy_and_install
    # remove the existing install (if any) and install a new one
    if File.exist?(FCKEDITOR_INSTALL_DIRECTORY)
      FileUtils.rm_r(FCKEDITOR_INSTALL_DIRECTORY)
    end
    # now install fresh
    install(true)
  end

  def FckeditorFileUtils.check_and_install
    # check to see if already installed, if not install
    unless File.exist?(FCKEDITOR_INSTALL_DIRECTORY)
      install(false)
    end
  end
end
