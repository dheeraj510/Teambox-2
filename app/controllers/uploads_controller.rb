class UploadsController < ApplicationController
  before_filter :find_upload, :only => [:destroy,:update,:thumbnail,:show]
  skip_before_filter :load_project, :only => [:download]
  SEND_FILE_METHOD = :default

  def download

    head(:not_found) and return if (upload = Upload.find_by_id(params[:id])).nil?
    head(:forbidden) and return unless upload.downloadable?(current_user)

    path = upload.asset.path(params[:style])
    unless File.exist?(path) && params[:filename].to_s == upload.asset_file_name
      head(:bad_request)
      raise "Unable to download file"
    end  

    mime_type = File.mime_type?(upload.asset_file_name)

    mime_type = 'application/octet-stream' if mime_type == 'unknown/unknown'

    send_file_options = { :type => mime_type }
    
    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end
  
  def new
    @upload = current_user.uploads.new
    respond_to { |f| f.html }
  end
  
  def index
    @uploads = @current_project.uploads
    @upload  = @current_project.uploads.new
  end
  
  def edit
    @upload = @current_project.uploads.find(params[:id])
  end
  
  def new
    @comment = load_comment
    @upload = @current_project.uploads.new(:user_id => current_user.id)
    if is_iframe?
      respond_to { |f| f.html { render :layout => 'upload_iframe' }}
    else
      respond_to { |f| f.html { render :template => 'uploads/new_upload' } }
    end
  end
  
  def create
    @upload = @current_project.uploads.new(params[:upload])
    @upload.user = current_user
    
    if is_iframe?
      @upload.save
      @comment = load_comment
      @upload.reload
      params[:basic_uploader] = true
      respond_to{|f|f.html {render :template => 'uploads/create', :layout => 'upload_iframe'} }
    else
      respond_to do |f|          
        if @upload.save
          @current_project.log_activity(@upload,'create')
          f.html { redirect_to(project_uploads_path(@current_project, :basic_uploader => true)) }
        else
          @uploads = @current_project.uploads
          params[:basic_uploader] = true
          f.html { render :index } 
        end   
      end
    end
  end


  def create_from_flash_upload
    @upload = @current_project.uploads.new(:user_id => params[:user_id])
    @upload.asset_original_file_name = params[:filename]
    unless params[:filename_prefix].blank?
      @upload.asset_file_name = "_#{params[:filename_prefix]}_#{@upload.asset_original_file_name}"
    else
      @upload.asset_file_name = @upload.asset_original_file_name
    end
    @upload.asset_file_size = params[:filesize]
    @upload.from_flash_uploader = true
    @upload.init_from_s3_upload

    if @upload.save!
      if is_iframe?
        @comment = load_comment
        @upload.reload
        thumb = render_to_string :partial => 'uploads/upload_edit', :collection => [@upload], :as => :upload, :locals => { :target => @comment, :no_wrapper => true }
        render :update do |page|
          page << "new Element('input', { 'name' : 'uploads[]', 'type' : 'hidden', 'value' : #{@upload.id.to_s} }).inject(window.top.$('uploads_save'), 'top')"
          page << "new Element('div', { class: 'upload_thumbnail', id : 'upload_#{@upload.id}', 'html': '#{escape_javascript(thumb)}' }).inject(window.top.$('uploads_current'), 'top')"
        end
      else
        upload_info = render_to_string :partial => 'uploads/upload', :object => @upload, :locals => { :project => @upload.project, :no_wrapper => true }

        render :update do |page|
          page << "new Element('div', { 'class' : 'upload', 'id' : 'upload_#{@upload.id}', 'html': '#{escape_javascript(upload_info)}' } ).inject($('content'), 'top')"
        end
      end
    else
      render :nothing => true
    end

  end

  
  def update
    @upload.update_attributes(params[:upload])

    respond_to do |format|
      format.js
      format.html { redirect_to(project_uploads_path(@current_project)) }
    end
  end
      
  def destroy
    if @upload
      @upload.destroy
    end
  end

  
  def validate_file_names
    file_names = params[:file_names].split(',')
    prefixes = []
    file_names.each do |file_name|
      prefixes << test_filename(file_name)
    end
    render :json => prefixes
  end

    
  private

    def test_filename file_name
      f_test = file_name
      pre_fix = 1
      while Upload.exists?(["asset_file_name = ?", f_test])
        f_test = "_#{pre_fix}_#{file_name}"
        pre_fix += 1
      end
      return (f_test != file_name ? (pre_fix - 1) : 'file_ok')
    end

    def is_iframe?
      params[:iframe] != nil
    end
        
    def load_comment
      if params[:comment_id]
        Comment.find(params[:comment_id])
      else
        @current_project.comments.new(:user_id => current_user.id)
      end
    end
    
    def find_upload
      if params[:id].match /^\d+$/
        @upload = @current_project.uploads.find(params[:id])
      else
        @upload = @current_project.uploads.find_by_upload_file_name(params[:id])
      end
      
    end

end