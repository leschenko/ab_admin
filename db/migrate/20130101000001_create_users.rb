class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table(:users) do |t|
      t.string :login
      t.integer :user_role_id, limit: 1, default: 1
      t.integer :gender, limit: 1, default: 1
      t.string :first_name
      t.string :last_name
      t.string :patronymic
      t.string :phone
      t.string :skype
      t.string :web_site
      t.string :address
      t.date :birthday

      t.string :time_zone
      t.string :locale, limit: 10
      t.string :bg_color, default: 'ffffff'

      ## Database authenticatable
      t.string :email
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Token authenticatable
      ## t.string :authentication_token

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token, :unique => true
    add_index :users, :unlock_token, :unique => true
  end
end