class AddOptionsListToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :option_list, :jsonb, default: {}
  end
end
