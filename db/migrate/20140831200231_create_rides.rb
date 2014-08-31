class CreateRides < ActiveRecord::Migration
  def change
    create_table :rides do |t|
      t.belongs_to :user
      t.belongs_to :vehicle
      t.string :relation # used for state machine
      t.boolean :owner
      t.timestamps
    end
  end
end
