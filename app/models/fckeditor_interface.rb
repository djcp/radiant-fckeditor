module FckeditorInterface
  def self.included(base)
    base.class_eval {
      before_filter :add_fckeditor_interface, :only => [:edit, :new]
      include FckeditorInstanceMethods
    }
  end
  
  module FckeditorInstanceMethods
    def add_fckeditor_interface
 #     @buttons_partials ||= []
 #     @buttons_partials << "attachments_box"
      include_javascript 'fckeditor/fckeditor'
 #     include_stylesheet 'admin/page_attachments'
    end
  end
end

