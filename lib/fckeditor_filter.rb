class FckeditorFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../fckeditor.html"
  def filter(text)
	  text
  end
end
