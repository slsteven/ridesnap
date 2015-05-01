class AddSpecsToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :specs, :jsonb
  end
end
