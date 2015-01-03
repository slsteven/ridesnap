class AddLeasedToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :financed, :boolean
    add_column :vehicles, :model_pretty, :string
  end
end
