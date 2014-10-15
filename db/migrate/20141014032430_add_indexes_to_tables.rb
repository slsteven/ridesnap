class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :users, :email
    add_index :users, :status

    add_index :vehicles, :zip_code
    add_index :vehicles, :status
    add_index :vehicles, :condition

    add_index :rides, :user_id
    add_index :rides, :vehicle_id
    add_index :rides, :relation

    add_index :images, :vehicle_id
  end
end
