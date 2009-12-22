# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.
 
ActiveRecord::Schema.define(:version => 20090825190238) do

  create_table :announcements, :force => true do |t|
    t.integer :user_id
    t.integer :comment_id
  end  

  create_table :cards, :force => true do |t|
    t.integer   :user_id
    t.boolean   :public, :default => false
  end
     
  create_table  :addresses, :force => true do |t|
    t.integer   :card_id
    t.string    :street
    t.string    :city
    t.string    :state
    t.string    :zip
    t.string    :country
    t.integer   :account_type, :default => 0
  end
       
  create_table  :email_addresses, :force => true do |t|
    t.integer   :card_id
    t.string    :name
    t.integer   :account_type, :default => 0
  end
  
  create_table  :phone_numbers, :force => true do |t|
    t.integer   :card_id
    t.string    :name
    t.integer   :account_type, :default => 0
  end
  
  create_table  :websites, :force => true do |t|
    t.integer   :card_id
    t.string    :name
    t.integer   :account_type, :default => 0
  end
    
  create_table  :ims, :force => true do |t|
    t.integer   :card_id
    t.string    :name
    t.integer   :account_im_type, :default => 0
    t.integer   :account_type, :default => 0
  end
      
  create_table  :social_networks, :force => true do |t|
    t.integer   :card_id
    t.string    :name
    t.integer   :account_network_type, :default => 0
    t.integer   :account_type, :default => 0
  end
        
  create_table :users, :force => true do |t|
    t.string   :login,                     :limit => 40
    t.string   :first_name,                :limit => 20, :default => ""
    t.string   :last_name,                 :limit => 20, :default => ""
    t.text     :biography, :default => "", :null => false
    t.string   :email,                     :limit => 100
    t.string   :crypted_password,          :limit => 40
    t.string   :salt,                      :limit => 40
    t.string   :remember_token,            :limit => 40
    t.datetime :remember_token_expires_at
    t.string   :time_zone,          :default => "Eastern Time (US & Canada)"
    t.string   :language,           :default => "en"
    t.text     :recent_projects
    t.boolean  :conversations_first_comment, :default => true
    t.string   :first_day_of_week, :default => 'sunday'
    t.integer  :invitations_count, :default => 0
    t.float    :profile_score, :default => 0
    t.float    :profile_percent, :default => 0
    t.string   :profile_grade
    t.string   :login_token,               :limit => 40
    t.datetime :login_token_expires_at    
    t.boolean  :welcome,        :default => false
    t.boolean  :confirmed_user, :default => false
    t.integer  :last_read_announcement
    t.datetime :deleted_at
    t.string   :rss_token, :default => nil, :limit => 40
    t.boolean  :admin,    :default => false
    t.integer  :comments_count, :default => 0

    t.boolean  :notify_mentions,      :default => true
    t.boolean  :notify_conversations, :default => true
    t.boolean  :notify_task_lists,    :default => true
    t.boolean  :notify_tasks,         :default => true

    t.string  :avatar_file_name
    t.string  :avatar_content_type
    t.integer :avatar_file_size
    t.timestamps
  end
 
  create_table :sessions do |t|
    t.string :session_id, :null => false
    t.text :data
    t.timestamps
  end
  
  create_table :projects do |t|
    t.integer :user_id
    t.string  :name
    t.string  :permalink
    t.integer :last_comment_id, :null => true, :default => nil
    t.integer :comments_count, :default => 0
    t.datetime :deleted_at
    t.timestamps
  end
  
  create_table :people do |t|
    t.integer :user_id
    t.integer :project_id
    t.integer :source_user_id
    t.datetime :deleted_at
    t.string :permissions
    t.integer :role, :default => 2
    t.timestamps
  end
 
  create_table :task_lists do |t|
    t.integer :project_id
    t.integer :user_id
    t.integer :page_id, :null => true, :default => nil
    t.string  :name
    t.integer :position
    t.integer :last_comment_id, :null => true, :default => nil
    t.integer :comments_count, :default => 0
    t.text    :watchers_ids
    t.boolean :archived, :default => false
    t.datetime :deleted_at  
    t.integer :archived_tasks_count, :default => 0
    t.integer :tasks_count, :default => 0
    t.datetime :completed_at
    t.date :start_on
    t.date :finish_on
    t.timestamps
  end
  
  create_table :tasks do |t|
    t.integer :project_id
    t.integer :page_id, :null => true, :default => nil
    t.integer :task_list_id
    t.integer :user_id
    t.string  :name
    t.integer :position
    t.integer :comments_count, :default => 0
    t.integer :last_comment_id, :null => true, :default => nil
    t.text    :watchers_ids
    t.integer :assigned_id
    t.integer :status, :default => 0
    t.boolean :archived, :default => false
    t.date :due_on
    t.datetime :completed_at
    t.datetime :deleted_at    
    t.timestamps
  end
 
  create_table :activities, :force => true do |t|
    t.integer  :user_id
    t.integer  :project_id
    t.integer  :target_id,   :limit => 11
    t.string   :target_type
    t.string   :action
    t.string   :comment_type
    t.datetime :deleted_at    
    t.timestamps
  end
  
  create_table :comments do |t|
    t.integer :target_id 
    t.string  :target_type
    t.integer :project_id
    t.integer :user_id
    t.text    :body
    t.text    :body_html
    t.float   :hours
    t.boolean :billable
    t.integer :status, :default => 0
    t.datetime :deleted_at    
    t.timestamps
  end
  
  create_table :comments_read do |t|
    t.integer :target_id
    t.string  :target_type
    t.integer :user_id
    t.integer :last_read_comment_id
  end
    
  create_table :conversations do |t|
    t.integer :project_id
    t.integer :user_id
    t.string  :name
    t.integer :last_comment_id, :null => true, :default => nil
    t.integer :comments_count, :default => 0
    t.text    :watchers_ids
    t.datetime :deleted_at
    t.timestamps
  end
  
  create_table :pages do |t|
    t.integer :project_id
    t.integer :user_id
    t.string  :name
    t.text    :description
    t.integer :last_comment_id, :null => true, :default => nil
    t.text    :watchers_ids
    t.datetime :deleted_at    
    t.timestamps
  end
  
  create_table :dividers do |t|
    t.integer :page_id
    t.integer :project_id
    t.string  :name
    t.integer :position
    t.datetime :deleted_at    
    t.timestamps
  end
  
  create_table :notes do |t|
    t.integer :page_id
    t.integer :project_id
    t.string  :name
    t.text :body
    t.text  :body_html
    t.integer :position
    t.integer :last_comment_id, :null => true, :default => nil
    t.datetime :deleted_at
    t.timestamps
  end
 
  create_table :invitations do |t|
    t.integer :user_id
    t.integer :project_id
    t.string  :email
    t.integer :invited_user_id
    t.string  :token
    t.datetime :deleted_at
    t.timestamps
  end
 
  create_table :uploads do |t|
    t.integer  :user_id
    t.integer  :project_id
    t.integer  :comment_id
    t.text     :description, :default => ''
    t.string   :asset_file_name
    t.string   :asset_content_type
    t.integer  :asset_file_size
    t.datetime :deleted_at
    t.string   :asset_original_file_name
    t.timestamps
  end
 
  add_index :sessions, :session_id
  add_index :sessions, :updated_at
 
  add_index :users,         :login, :unique => true
  add_index :projects,      :permalink
  add_index :activities,    :project_id
  add_index :activities,    :created_at
  add_index :people,        [:user_id,:project_id]
  add_index :comments,      [:target_type,:target_id,:user_id]

  add_index :activities,    :deleted_at
  add_index :comments,      :deleted_at
  add_index :conversations, :deleted_at
  add_index :task_lists,    :deleted_at
  add_index :tasks,         :deleted_at
  add_index :pages,         :deleted_at
  add_index :notes,         :deleted_at
  add_index :projects,      :deleted_at
  add_index :users,         :deleted_at

  add_index :conversations, :project_id
  add_index :task_lists,    :project_id
  add_index :pages,         :project_id
  add_index :tasks,         :project_id
  add_index :tasks,         :task_list_id
  
  add_index :uploads,       :comment_id

  add_index :comments_read, [:target_type,:target_id,:user_id]
  
  create_table :emails, :force => true do |t|
    t.string   :from
    t.string   :to
    t.integer  :last_send_attempt, :default => 0
    t.text     :mail
    t.datetime :created_on
  end

  create_table :reset_passwords do |t|
    t.integer :user_id
    t.string :reset_code
    t.datetime :expiration_date

    t.timestamps
  end 
end