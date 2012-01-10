namespace :radiant do
	namespace :extensions do
		namespace :fckeditor do

			desc "Runs the migration of the Fckeditor extension"
			task :migrate => :environment do
				require 'radiant/extension_migrator'
				if ENV["VERSION"]
					FckeditorExtension.migrator.migrate(ENV["VERSION"].to_i)
				else
					FckeditorExtension.migrator.migrate
				end
			end

			desc "Copies public assets of the Fckeditor to the instance public/ directory."
			task :update => :environment do
				# Update to work with v1.0.0-rc3 and greater
				#require "config/environment"
				require 'fileutils'
				directory = FckeditorExtension.root
				require "#{directory}/lib/fckeditor"
				require "#{directory}/lib/fckeditor_version"
				require "#{directory}/lib/fckeditor_file_utils"
				puts "** Installing Radiant FCKEditor Extension version #{FckeditorExtension.version}..."           
				FckeditorFileUtils.destroy_and_install 
				puts "** Successfully installed Radiant FCKEditor Extension version #{FckeditorExtension.version}"
			end
		end  
	end
end
