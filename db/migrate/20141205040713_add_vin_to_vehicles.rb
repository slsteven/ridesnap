class AddVinToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :vin, :string
  end
end
