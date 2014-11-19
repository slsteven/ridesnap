class AddCanceledToRide < ActiveRecord::Migration
  def change
    add_column :rides, :cancel, :boolean, default: false
  end
end
