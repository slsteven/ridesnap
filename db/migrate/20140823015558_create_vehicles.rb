class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.string :style
      t.integer :mileage
      t.string :condition
      t.hstore :options
      t.hstore :preliminary_value
      t.hstore :agreed_value
      t.decimal :sold_price
      t.string :status # used for state machine
      t.boolean :inspection
      t.string :zip_code

      t.timestamps
    end
  end
end
