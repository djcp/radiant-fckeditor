module FckeditorInterface
  def self.included(base)
    base.class_eval {
      include FckeditorInstanceMethods
      before_filter :add_fckeditor_interface, :only => [:edit, :new]
    }
  end

  module FckeditorInstanceMethods
    def add_fckeditor_interface
      include_javascript 'fckeditor/fckeditor'
      include_javascript 'fckeditor/observe'
    end
  end
end

