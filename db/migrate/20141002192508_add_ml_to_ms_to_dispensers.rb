class AddMlToMsToDispensers < ActiveRecord::Migration
  def up
  	add_column :dispensers, :ml_to_ms, :text
  	Dispenser.reset_column_information
  	Dispenser.all.each do |d|
  		d.ml_to_ms = [{'low' => 58, 'med' => 58, 'high' => 58}]*d.n_bottles
  		d.save
  	end
  end

  def down
  end
end
