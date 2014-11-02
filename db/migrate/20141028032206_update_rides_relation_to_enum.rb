class UpdateRidesRelationToEnum < ActiveRecord::Migration
  def up
    Ride.all.each do |r|
      r.relation = case r.relation
      when 'seller' then 1
      when 'tester' then 2
      when 'buyer' then 3
      else nil
      end
      r.save!
    end
    change_column :rides, :relation, 'integer USING CAST(relation AS integer)'
  end
  def down
    change_column :rides, :relation, 'string USING CAST(relation AS string)'
  end
end