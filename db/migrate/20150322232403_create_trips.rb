class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.belongs_to :vehicle
      t.jsonb :details

      t.timestamps null: false
    end
    add_index :trips, :vehicle_id
  end
end