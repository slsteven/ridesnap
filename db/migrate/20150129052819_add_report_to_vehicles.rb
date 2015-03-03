class AddReportToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :report, :jsonb, default: {}
  end
end
