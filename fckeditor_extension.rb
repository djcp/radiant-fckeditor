# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class FckeditorExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/fckeditor"
  
  # define_routes do |map|
  #   map.connect 'admin/fckeditor/:action', :controller => 'admin/fckeditor'
  # end
  
  def activate
    # admin.tabs.add "Fckeditor", "/admin/fckeditor", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Fckeditor"
  end
  
end