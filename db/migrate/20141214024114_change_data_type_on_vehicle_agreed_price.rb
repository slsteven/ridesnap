class ChangeDataTypeOnVehicleAgreedPrice < ActiveRecord::Migration
  def change
    remove_column :vehicles, :agreed_value, :hstore
    add_column :vehicles, :agreed_value, :decimal
  end
end
