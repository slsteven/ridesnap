class AddExternalIdToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :external_id, :string
    remove_column :authentications, :vehicle_id, :integer
  end
end
