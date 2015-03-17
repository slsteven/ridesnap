class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :vehicle
      t.string :type
      t.jsonb :details
      t.timestamps null: false
      t.timestamp :ended_at
    end
    add_index :notifications, :vehicle_id
    add_index :notifications, :type
    add_index :notifications, :ended_at
  end
end
