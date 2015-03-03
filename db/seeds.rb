# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  50.times do
    mk = Settings.vehicle_makes.to_hash.keys.map(&:to_s).sample
    models = Edmunds.query_models(mk)
    md = models.keys.sample
    yr = Edmunds.query_years(mk, md).keys.reject{ |i| i < Date.today.year-10 }.sample
    next unless yr
    styles = Edmunds.query_styles(mk, md, yr)
    st = styles.keys.sample
    desc = styles[st]
    value = Edmunds.typical_value(st)
    next unless value.kind_of?(Hash)
    sources = [value[:trade_in], value[:private_party]]
    avg = sources.sum / sources.size.to_f
    vl = {}
    vl[:snap_up] = avg.round(-2)
    vl[:trade_in] = value[:trade_in].round(-2)
    vl[:ride_snap] = value[:private_party].round(-2)
    next if vl[:ride_snap].zero?
    @veh = Vehicle.create( make: mk,
                           model: md,
                           model_pretty: models[md],
                           year: yr,
                           style: st,
                           description: desc,
                           mileage: [*1000..200000].sample,
                           preliminary_value: vl,
                           condition: [*1..5].sample,
                           inspection: true,
                           zip_code: Faker::Address.zip_code[0..4] )
    @veh.list!
    sleep 0.3
    puts "#{@veh.info} -- created"
  end
end

