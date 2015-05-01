class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.belongs_to :vehicle
      t.string :type
      t.string :grant
      t.jsonb :token

      t.timestamps null: false
    end

    add_index :authentications, :type
    add_index :authentications, :vehicle_id
  end
end
