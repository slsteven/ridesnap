class AddClosestColorToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :closest_color, :string
    add_index :vehicles, :closest_color
  end
end
