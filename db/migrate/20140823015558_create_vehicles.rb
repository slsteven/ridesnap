class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.integer :year
      t.string :make
      t.string :model
      t.string :trim
      t.integer :mileage
      t.string :condition
      t.string :status # used for state machine
      t.boolean :inspection
      t.string :zip_code

      t.timestamps
    end
  end
end
