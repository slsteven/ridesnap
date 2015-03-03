class UpdateVehicleConditionToEnum < ActiveRecord::Migration
  def up
    change_column :vehicles, :condition, 'integer USING CAST(condition AS integer)'
  end
  def down
    change_column :vehicles, :condition, 'string USING CAST(condition AS string)'
  end
end
