class AddInReplyToToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :in_reply_to, :integer, default:0, foreign_key:{ to_table: :users }
    add_index :microposts, [:in_reply_to, :created_at]
  end
end

