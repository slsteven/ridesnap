class AddTripToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :trip_id, :integer
    add_index :notifications, :trip_id
    add_index :notifications, :details, using: :gin
    add_index :trips, :details, using: :gin
  end
end
