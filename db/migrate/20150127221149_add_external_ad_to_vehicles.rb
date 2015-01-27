class AddExternalAdToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :external_ad, :string
  end
end
