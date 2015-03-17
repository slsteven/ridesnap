class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :code
      t.string :description
      t.timestamps null: false
    end
    add_index :codes, :code
  end
end
