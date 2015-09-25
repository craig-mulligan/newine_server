class Dispenser < ActiveRecord::Base
	has_many :bottle_holders, :dependent => :destroy
	has_many :temperature_controls, :dependent => :destroy

	serialize :ml_to_ms, Array

	validates :uid, :uniqueness => true
	#after_save :create_bottle_holders, :on => :create

	def self.default_ml_to_ms(n_bot)
		[{'low' => 58, 'med' => 58, 'high' => 58}]*n_bot
	end

	def create_bottle_holders
		self.n_bottles.times do |t|
			self.bottle_holders.create(:dispenser_index => t)
		end
	end
	def create_temperature_controls
		self.n_temperature_controls.times do |t|
			self.temperature_controls.create(:dispenser_index => t, :temperature => 18)
		end
	end

	def configure
		data = {}
		data['serving_options'] = []
		data['wine_names'] = []
		data['wine_details'] = []
		data['remaining_volumes'] = []
		self.bottle_holders.reverse.each_with_index do |bh, index|
			data['serving_options'][index] = {}

			data['serving_options'][index]['low'] = {:price=>bh.serving_price_low,:volume=>bh.serving_volume_low}
			data['serving_options'][index]['med'] = {:price=>bh.serving_price_med,:volume=>bh.serving_volume_med}
			data['serving_options'][index]['high'] = {:price=>bh.serving_price_high,:volume=>bh.serving_volume_high}
			data['wine_names'][index] = (bh.wine ? bh.wine.name : 'Vacio')
			data['wine_details'][index] = (bh.wine ? bh.wine.variety + ' ' + bh.wine.vintage.to_s : '')
			data['remaining_volumes'][index] = bh.remaining_volume
		end

		data['ml_to_ms'] = self.ml_to_ms


		data['temperatures'] = []

		self.temperature_controls.each do |tc|
			data['temperatures'][tc.dispenser_index] = tc.temperature
		end

		p data.to_json
		p "Printing ip"
		p self.ip
		RestClient.post(self.ip + ':3001',data.to_json + "\n",:content_type => :json, :accept => :json)
	end
	def shutdown
		RestClient.post(self.ip + ':3001',"SHUTDOWN" + "\n",:content_type => :json, :accept => :json)
		self.online = false
		self.save
		$channel.push({:dispenser=>{:id=> self.id,:online=>false}}.to_json)
	end
end