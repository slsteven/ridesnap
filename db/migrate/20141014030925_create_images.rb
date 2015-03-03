class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.belongs_to :vehicle
      t.string :url
      t.boolean :default
      t.timestamps
    end
  end
end
