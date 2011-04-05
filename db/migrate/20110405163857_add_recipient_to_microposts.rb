class AddRecipientToMicroposts < ActiveRecord::Migration
  def self.up
    add_column :microposts, :recipient_id, :integer
  end

  def self.down
    remove_column :microposts, :recipient_id
  end
end
