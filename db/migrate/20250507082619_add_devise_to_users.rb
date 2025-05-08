class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def self.up
    change_table :users, bulk: true do |t|
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end

    # reset_password_tokenにインデックスを追加
    add_index :users, :reset_password_token, unique: true

    # user_nameのインデックスが存在しない場合のみ追加
    unless index_exists?(:users, :user_name)
      add_index :users, :user_name, unique: true
    end
  end

  def self.down
    change_table :users, bulk: true do |t|
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
    end

    # user_nameインデックスが存在する場合にのみ削除
    if index_exists?(:users, :user_name)
      remove_index :users, :user_name
    end

    remove_index :users, :reset_password_token
  end
end


