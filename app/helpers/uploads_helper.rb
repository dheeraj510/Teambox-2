module UploadsHelper

  require 'base64'
  require 'openssl'
  require 'digest/sha1'

  def upload_form_for(project,upload,&proc)
    raise ArgumentError, "Missing block" unless block_given?
    form_for [project,upload], 
      :html => { 
        :id => 'edit_upload', 
        :multipart => true, 
        :style => "#{ 'display: none' if upload.errors.empty?}", 
        :class => "upload_form app_form #{'form_error' unless upload.errors.empty?}" },
        &proc
  end
  
  def upload_primer(project)
    render :partial => 'uploads/primer', :locals => { :project => project }
  end

  def the_comment_upload_link(comment, options = {})
    link_to_function image_tag('attach_button.jpg'), show_upload_form(comment), :id => 'comment_upload_link', :style => options[:hide] ? 'display:none' : ''
  end

  def upload_iframe_form(comment)
    render :partial => 'uploads/iframe_upload', 
    :locals => { 
      :comment => comment }    
  end

  def upload_form(project,upload)
    render :partial => 'uploads/form', :locals => { :project => project, :upload => upload }
  end

  def show_upload(upload)
    # TODO: Find why some uploads get saved as with :file_type => nil
    if upload and upload.file_type
      render :partial => 'uploads/upload', :locals => { :project => upload.project, :upload => upload }
    end
   end

  def list_uploads(project,uploads)
    render :partial => 'uploads/upload', :collection => uploads, :as => :upload, :locals => { :project => project }    
  end

  def edit_upload_form(project,upload)
    render :partial => 'uploads/edit', :locals => {
      :project => project,
      :upload => upload }
  end
      
  def upload_actions_links(upload)
    render :partial => 'uploads/actions',
    :locals => { 
      :upload => upload }
  end

  def upload_link(project,upload)
    if upload.file_name.length > 40
      file_name = upload.original_filename.sub(/^.+\./,truncate(upload.file_name,38,'~.'))
    else
      file_name = upload.original_filename
    end  

    link_to file_name, upload.url, :class => 'upload_link'
  end
    
  def upload_link_with_thumbnail(upload)
    link_to image_tag(upload.asset(:thumb)),
      upload.url,
      :class => 'link_to_upload'
  end

  def upload_area(comment)
    render :partial => 'uploads/upload_area', :locals => {:comment => comment }
  end

  def show_upload_form(comment)
    update_page do |page|
      page['upload_area'].show
      page['comment_upload_link'].hide
    end  
  end

  def insert_upload_form(comment)
    page.insert_html :after, "upload_area",
      :partial => 'uploads/iframe_upload', 
      :locals => { 
        :comment => comment, 
        :project => comment.project }
  end
  
  def upload_form_url_for(comment)
    if comment.new_record?
      project_uploads_url(comment.project)
    else
      project_comment_uploads_url(comment.project,comment)
    end
  end
  
  def upload_url_for(comment)
    if comment.new_record?
      new_project_upload_url(comment.project)
    else
      new_project_comment_upload_url(comment.project,comment)
    end
  end
  
  def list_uploads_edit(uploads,target)
    render :partial => 'uploads/upload_edit', :collection => uploads, :as => :upload, :locals => { :target => target }
  end
  
  def list_uploads_inline(uploads)
    render :partial => 'uploads/file', :collection => uploads, :as => :upload
  end

  def list_uploads_inline_with_thumbnails(uploads)
    render :partial => 'uploads/thumbnail', :collection => uploads, :as => :upload
  end
  
  def observe_upload_form
    update_page_tag do |page|
      page['upload_file'].observe('change') do |page|
        page['new_upload'].submit
        page['new_upload'].hide
        page['upload_iframe_form_loading'].show
      end
    end
  end
  
  def cancel_upload_form_link
    link_to_function 'cancel', cancel_upload_form
  end
  

  def delete_upload_link(upload,target = nil)
    if target.nil?
      link_to_remote trash_image, 
        :url => project_upload_path(upload.project,upload), 
        :method => :delete, 
        :class => 'delete_link', 
        :confirm => "Are you sure you want to delete this file?"
    else
      link_to_function 'Remove', delete_upload(upload,target), :class => 'remove'
    end
  end

  def upload_form_params(comment)
    render :partial => 'uploads/iframe_upload', :locals => { :comment => comment, :upload => Upload.new }
  end
  
  def upload_save_tag(name,upload)
    content_tag(:input,nil,{ :name => name,:type => 'hidden',:value => upload.id.to_s })
  end
  
  def add_upload_link(project)
    return unless project.editable?(current_user)
    link_to_function content_tag(:span, t('.new_file')), show_new_upload_form, :class => 'add_button', :id => "add_upload_link"
  end
  
  def show_new_upload_form
    update_page do |page|
      page['edit_upload'].show
      page['add_upload_link'].hide
    end
  end
    
  def delete_upload(upload,target)
    if target.new_record?
      update_page do |page|
        page["upload_#{upload.id}"].up('.uploads_current') \
          .previous('.uploads_save').select("input[value=#{upload.id}]") \
          .invoke('remove')
        page << "var uploads_current = $('upload_#{upload.id}').up('.uploads_current');"
        page["upload_#{upload.id}"].remove
        page << "Comment.update_uploads_current(uploads_current);"
      end
    else
      update_page do |page|
        page << "$('upload_#{upload.id}').up('.uploads_current')" + \
          ".previous('.uploads_save').insert(" + \
          { :top => upload_save_tag('uploads_deleted[]',upload) }.to_json + ");"
        page["upload_#{upload.id}"].remove
      end
    end
  end
  
  def edit_upload_link(upload)
    link_to_function pencil_image, show_edit_upload_form(upload), :class => 'edit_upload_link'
  end
    
  def show_edit_upload_form(upload)
    return unless upload.editable?(current_user)
    update_page do |page|
      page["upload_#{upload.id}"].down('.show_details').hide
      page["upload_#{upload.id}"].down('.edit_details').show
    end
  end
  
  
  def cancel_edit_link(upload)
    link_to_function t('common.cancel'), update_page { |page| page.hide_upload_form(upload) }
  end
  
  def file_icon_image(upload,size='48px')
    extension = File.extname(upload.file_name)
    if extension.length > 0
      extension = extension[1,10]
    end
    
    if Upload::ICONS.include?(extension)
      image_tag("file_icons/#{size}/#{extension}.png", :class => "file_icon #{extension}")
    else
      image_tag("file_icons/#{size}/_blank.png")
    end
  end


  def s3_uploader(options = {})
    s3_config_filename = "#{RAILS_ROOT}/config/amazon_s3.yml"
    config = YAML.load_file(s3_config_filename)

    bucket            = config[RAILS_ENV]['bucket_name']
    access_key_id     = config[RAILS_ENV]['access_key_id']
    secret_access_key = config[RAILS_ENV]['secret_access_key']

    key             = options[:key] || ''
    content_type    = options[:content_type] || '' # Defaults to binary/octet-stream if blank
    acl             = options[:acl] || 'public-read'
    expiration_date = (options[:expiration_date] || 10.hours).from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    max_filesize    = options[:max_filesize] || 2.megabyte

    id = options[:id] ? "_#{options[:id]}" : ''

    policy = Base64.encode64(
      "{'expiration': '#{expiration_date}',
        'conditions': [
          {'bucket': '#{bucket}'},
          ['starts-with', '$key', '#{key}'],
          {'acl': '#{acl}'},
          {'success_action_status': '201'},
          ['content-length-range', 0, #{max_filesize}],
          ['starts-with', '$Filename', ''],
          ['starts-with', '#{content_type}', '']
        ]
      }").gsub(/\n|\r/, '')

    signature = Base64.encode64(
                  OpenSSL::HMAC.digest(
                    OpenSSL::Digest::Digest.new('sha1'),
                    secret_access_key, policy)).gsub("\n","")

    out = ""

    out << "\n"
    out << link_to("<strong>" + (options[:text] || 'Upload File(s)') + '</strong>', '#', :id => "upload_link#{id}")
    out << "\n"
    out << content_tag(:ul, '', :id => "uploader_file_list#{id}", :class => 'uploader_file_list' )
    out << "\n"

    out << javascript_tag("window.addEvent('domready', function() {

      /**
       * Uploader instance
       */

      var up#{ id } = new FancyUpload3.S3Uploader( 'uploader_file_list#{id}', '#upload_link#{id}', {
                                                   host: '#{request.host_with_port}',
                                                   bucket: '#{bucket}',
                                                   typeFilter: #{options[:type_filter] ? "{" + options[:type_filter] + "}" : 'null' },
                                                   fileSizeMax: #{options[:max_filesize]},
                                                   access_key_id: '#{access_key_id}',
                                                   policy: '#{policy}' ,
                                                   signature: '#{signature}',
                                                   key: '#{key}',
                                                   id: '#{id}',
                                                   acl: '#{acl}',
                                                   validateFileNamesURL: '#{options[:validate_filenames_url]}',
                                                   onUploadCompleteURL: '#{options[:on_complete]}',
                                                   onUploadCompleteMethod: '#{options[:on_complete_method]}',
                                                   formAuthenticityToken: '#{form_authenticity_token}'
                                                   //verbose: true
    })
  });")

  end


end
