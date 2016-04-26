class NewineServer < Sinatra::Application
	post '/bottle_holder/taste' do
		data = JSON.parse(request.body.read)
		@bottle_holder = BottleHolder.where(dispenser_id: data['dispenser_id'], dispenser_index: data['dispenser_index']).last
		@bottle_holder.taste
		@dispenser = @bottle_holder.dispenser
		@dispenser.configure
		{ status: 200, id: @bottle_holder.id }.to_json
	end

	post '/bottle_holder/reload' do
		data = JSON.parse(request.body.read)
		@bottle_holder = BottleHolder.where(dispenser_id: data['dispenser_id'], dispenser_index: data['dispenser_index']).last
		@bottle_holder.update(remaining_volume: @bottle_holder.wine.volume, date_bottle_change: Date.today)
		@dispenser = @bottle_holder.dispenser
		@dispenser.configure
		{ status: 200, id: @bottle_holder.id }.to_json
	end

	post '/bottle_holder/days_bottle_change' do
		data = JSON.parse(request.body.read)
		@bottle_holder = BottleHolder.where(dispenser_id: data['dispenser_id'], dispenser_index: data['dispenser_index']).last
		{ status: 200, days: @bottle_holder.open_days }.to_json
	end

end
