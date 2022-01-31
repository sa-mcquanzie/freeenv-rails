# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :access_token, null: false, default: ''
      t.string :avatar, null: false, default: ''
      t.string :email, null: false, default: ''
      t.string :name, null: false, default: ''
      t.string :refresh_token, null: false, default: ''
      t.string :uid, null: false, default: ''
      t.string :username, null: false, default: ''
      t.datetime :remember_created_at
      t.datetime :token_expiration_time, null: false
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
