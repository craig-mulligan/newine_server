class NewineServer < Sinatra::Application

	get '/wines.?:format?' do
		if params[:q]
			@wines = Wine.where('name like ? or vintage like ? or brand like ?','%' + params[:q] + '%','%' + params[:q] + '%','%' + params[:q] + '%').
			paginate(:page=>params[:page], :per_page=>5)
		elsif params[:format] != 'json'
			@wines = Wine.paginate(:page=>params[:page], :per_page=>5)
		else
			@wines = Wine.all
		end
		format_render params[:format], :"wines/index"
	end

	get '/wines/:id.json' do
		@wine = Wine.where(:id => params[:id]).first
		if @wine.nil?
			raise Sinatra::NotFound
		end
		format_render 'json', :"wines/show"
	end

	get '/wines/:id' do
		@wines = Wine.where(:id => params[:id]).paginate(:page=>params[:page], :per_page=>5)
		format_render 'html', :"wines/index"
	end

	post '/wines' do
		@wine = Wine.create(params[:wine])
		p 'created wine'
		if @wine.valid?
			Event.log(
				"Nuevo Vino",
				@wine.name + ", " + @wine.variety.to_s + " " + @wine.vintage.to_s,
				"/wines/" + @wine.id.to_s,
				0xA88,
				"new_wine")
			redirect to('/wines/' + @wine.id.to_s)
		else
			redirect to('/wines')
		end
	end

	post '/wines/edit/:id' do
		@wines = Wine.where(:id => params[:id]).paginate(:page=>params[:page], :per_page=>5)
		@wine = @wines.first
		if(@wine)
			@wine.update_attributes(params[:wine])
		end
		format_render 'html', :"wines/index"
	end

	get '/all_wines.json' do
		@wines = Wine.all
		format_render 'json', :"wines/all"
	end

	post "/wines/destroy/:id" do
		@wine = Wine.find(params[:id])
		@wine.destroy
		redirect "/wines"
	end
end
