require 'fileutils'
require 'tmpdir'

class FckeditorController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  protect_from_forgery :except => [:command,:check_spelling,:config]
  UPLOADED = "/uploads"
  UPLOADED_ROOT = RAILS_ROOT + "/public" + UPLOADED
  MIME_TYPES = [
	"image/jpg",
	"image/jpeg",
	"image/pjpeg",
	"image/gif",
	"image/png",
	"application/x-shockwave-flash",
	"application/msword",
	"application/msaccess",
	"application/vnd.ms-excel",
	"application/vnd.ms-powerpoint",
	"application/vnd.oasis.opendocument.graphics",
	"application/vnd.oasis.opendocument.text",
	"application/vnd.oasis.opendocument.spreadsheet",
	"application/vnd.oasis.opendocument.presentation",
	"application/vnd.oasis.opendocument.database",
	"application/vnd.sun.xml.calc",
	"application/vnd.sun.xml.impress",
	"application/vnd.sun.xml.writer",
	"application/x-xcf",
	"text/plain",
	"text/html",
	"application/pdf",
	"application/ogg",
	"audio/mpeg",
	"audio/mpegurl",
	"audio/x-mpegurl",
	"image/tiff",
	"video/mpeg",
	"video/mp4",
	"video/qt",
	"video/quicktime",
	"video/x-flv",
	"video/x-ms-wmv",
	"video/x-msvideo",
	"application/zip",
	"application/xml",
	"application/xhtml+xml"
  ]
  
  RXML = <<-EOL
  xml.instruct!
    #=> <?xml version="1.0" encoding="utf-8" ?>
  xml.Connector("command" => params[:Command], "resourceType" => 'File') do
    xml.CurrentFolder("url" => @url, "path" => params[:CurrentFolder])
    xml.Folders do
      @folders.each do |folder|
        xml.Folder("name" => folder)
      end
    end if !@folders.nil?
    xml.Files do
      @files.keys.sort.each do |f|
        xml.File("name" => f, "size" => @files[f])
      end
    end if !@files.nil?
    xml.Error("number" => @errorNumber) if !@errorNumber.nil?
  end
  EOL
 
  def config
	  tag_list = []
	  class_name = params[:class_name]
	  class_name.constantize.tag_descriptions.sort.each do |tag_name, description|
		  tag_list << tag_name
	  end
	  @fck_tag_list = tag_list.collect{|tag| 'R:' + tag.upcase}.join('|') 
	  respond_to do |format|
		  format.js 
	  end
  end

  # figure out who needs to handle this request
  def command   
    if params[:Command] == 'GetFoldersAndFiles' || params[:Command] == 'GetFolders'
      get_folders_and_files
    elsif params[:Command] == 'CreateFolder'
      create_folder
	  elsif params[:Command] == 'FileUpload'
 	    upload_file
 	  end
 	  render :inline => RXML, :type => :rxml unless params[:Command] == 'FileUpload'
 	end 
 	
  def get_folders_and_files(include_files = true)
    @folders = Array.new
    @files = {}
    begin
      @url = upload_directory_path
      @current_folder = current_directory_path
      Dir.entries(@current_folder).each do |entry|
        next if entry =~ /^\./
        path = @current_folder + entry
        @folders.push entry if FileTest.directory?(path)
        @files[entry] = (File.size(path) / 1024) if (include_files and FileTest.file?(path))
      end
    rescue => e
      @errorNumber = 110 if @errorNumber.nil?
    end
  end

  def create_folder
    begin 
      @url = current_directory_path
      path = @url + params[:NewFolderName]
      if !(File.stat(@url).writable?)
        @errorNumber = 103
      elsif params[:NewFolderName] !~ /[\w\d\s]+/
        @errorNumber = 102
      elsif FileTest.exists?(path)
        @errorNumber = 101
      else
        Dir.mkdir(path,0775)
        @errorNumber = 0
      end
    rescue => e
      @errorNumber = 110 if @errorNumber.nil?
    end
  end
  
  def upload_file
    begin
      @new_file = check_file(params[:NewFile])
      @url = upload_directory_path
      ftype = @new_file.content_type.strip
      if ! MIME_TYPES.include?(ftype)
        @errorNumber = 202
        puts "#{ftype} is invalid MIME type"
        raise "#{ftype} is invalid MIME type"
      else
        path = current_directory_path + "/" + @new_file.original_filename
        File.open(path,"wb",0664) do |fp|
          FileUtils.copy_stream(@new_file, fp)
        end
        @errorNumber = 0
      end
    rescue => e
      @errorNumber = 110 if @errorNumber.nil?
    end

    render :text => %Q'
    <script>
      if (window.parent.frames[\'frmUpload\']) {
        window.parent.frames[\'frmUpload\'].OnUploadCompleted(#{@errorNumber});
      }
    </script>'
  end

  def upload
    self.upload_file
  end
  
  def check_spelling
    require 'cgi'
    @original_text = params[:textinputs] ? params[:textinputs].first : ''
    plain_text = strip_tags(CGI.unescape(@original_text))
    @words = FckeditorSpellCheck.check_spelling(plain_text)
    render :file => "#{FckeditorExtension.root}/app/views/fckeditor/spell_check.rhtml"
  end
  
  private
  def current_directory_path
    base_dir = "#{UPLOADED_ROOT}/#{params[:Type]}"
    Dir.mkdir(base_dir,0775) unless File.exists?(base_dir)
    check_path("#{base_dir}#{params[:CurrentFolder]}")
  end
  
  def upload_directory_path
    uploaded = request.relative_url_root.to_s+"#{UPLOADED}/#{params[:Type]}"
    "#{uploaded}#{params[:CurrentFolder]}"
  end
  
  def check_file(file)
    # check that the file is a tempfile object
    # RAILS_DEFAULT_LOGGER.info "CLASS OF UPLOAD OBJECT: #{file.class}"
    unless file.class.to_s.match(/tempfile|stringio|file/i)
      @errorNumber = 403
      throw Exception.new
    end
    file
  end
  
  def check_path(path)
    exp_path = File.expand_path path
    if exp_path !~ %r[^#{File.expand_path(RAILS_ROOT)}/public#{UPLOADED}]
      @errorNumber = 403
      throw Exception.new
    end
    path
  end
end
