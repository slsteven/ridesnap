class AddZipCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :zip_code, :string
    remove_column :users, :admin, :boolean
    add_column :users, :status, :string
  end
end
