class CreateGarages < ActiveRecord::Migration
  def change
    create_table :garages do |t|
      t.belongs_to :user
      t.belongs_to :vehicle
      t.timestamps
    end

    add_index :garages, :user_id
    add_index :garages, :vehicle_id
  end
end
