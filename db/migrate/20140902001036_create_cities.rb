class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :city
      t.string :state
      t.string :country
      t.integer :requests, default: 0
      t.boolean :available, default: false

      t.timestamps
    end
  end
end
