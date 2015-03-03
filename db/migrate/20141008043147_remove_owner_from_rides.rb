class RemoveOwnerFromRides < ActiveRecord::Migration
  def change
    remove_column :rides, :owner, :boolean
  end
end
