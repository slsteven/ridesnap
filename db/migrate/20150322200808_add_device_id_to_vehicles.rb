class AddDeviceIdToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :device_id, :string
    remove_column :vehicles, :options, :hstore
  end
end
