class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :phone, limit: 8
      t.string :password_digest
      t.string :remember_token
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
