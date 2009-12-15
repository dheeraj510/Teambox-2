class Upload < RoleRecord


  ICONS = %w(aac ai aiff avi bmp c cpp css dat dmg doc dotx dwg dxf eps exe flv gif h hpp html ics iso java jpg key mid mp3 mp4 mpg odf ods odt otp ots ott pdf php png ppt psd py qt rar rb rtf sql tga tgz tiff txt wav xls xlsx xml yml zip)
    
  belongs_to :user
  belongs_to :comment
  belongs_to :project

  default_scope :order => 'created_at DESC'

  attr_accessor :from_flash_uploader

  has_attached_file :asset,
                    :styles => { :thumb => "64x48#" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
                    :path => "assets/:project_permalink/:style/:filename",
                    :bucket => 'teambox'

  before_post_process :image?

  validates_attachment_size :asset, :less_than => APP_CONFIG['asset_max_file_size'].to_i.megabytes
  validates_attachment_presence :asset
  
  def image?
    !(asset_content_type =~ /^image.*/).nil?
  end

  def url(*args)
    u = asset.url(*args)
    u.sub(/\.$/,'')
    #'http://' + APP_CONFIG['app_domain'] + u
  end

  def file_name
    asset_file_name
  end

  def size
    asset_file_size
  end


  def downloadable?(user)
    true
  end
  
  def file_type
    ext = File.extname(file_name).sub('.','')
    ext = '...' if ext == ''
    ext
  end

  def init_from_s3_upload
    self.asset_content_type = file_extension_content_type(self.asset_file_name)
#    acl_obj = self.asset.s3_object.acl
#    if acl_obj.grants.find { |g| g.to_s =~ /READ to AllUsers/ }
#      self.acl = 'public-read'
#    else
#      self.acl = 'private'
#    end
  end

  def after_create
    post_process if self.from_flash_uploader
    #self.send_later(:post_process)
  end

  def post_process
    self.asset.reprocess!
  end

  def file_extension_content_type filename
    types = MIME::Types.type_for(filename)
    types.empty? ? nil : types.first.content_type
  end

  
end