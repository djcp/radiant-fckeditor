# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class FckeditorExtension < Radiant::Extension
  version "1.0"
  description "Adds the FCKEditor editor - with file uploads and spell checking."
  url "http://github.com/djcp/radiant-fckeditor/tree/master"

#  require 'fckeditor'
#  require 'fckeditor_version'
#  require 'fckeditor_file_utils'
#  require 'fckeditor_filter'

  FckeditorFileUtils.check_and_install

  # make plugin controller available to app
#  config.load_paths += %W(#{Fckeditor::PLUGIN_CONTROLLER_PATH} #{Fckeditor::PLUGIN_HELPER_PATH})

#  Rails::Initializer.run(:set_load_path, config)

 # ActionView::Base.send(:include, Fckeditor::Helper)

   define_routes do |map|
     map.connect 'fckeditor/:action', :controller => 'fckeditor'
	 map.connect 'fckeditor/check_spelling', :controller => 'fckeditor', :action => 'check_spelling'
	 map.connect 'fckeditor/command', :controller => 'fckeditor', :action => 'command'
	 map.connect 'fckeditor/upload', :controller => 'fckeditor', :action => 'upload'
   end
  
  def activate
    # admin.tabs.add "Fckeditor", "/admin/fckeditor", :after => "Layouts", :visibility => [:all]
	admin.page.edit.add :part_controls, "editor_control"
	Admin::PageController.send :include, FckeditorInterface
	FckeditorFilter
  end
  
  def deactivate
    # admin.tabs.remove "Fckeditor"
  end
  
end
