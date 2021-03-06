class User < ActiveRecord::Base
	has_many :tags, dependent: :destroy
	has_many :servings
	belongs_to :category

	validates :client_type, inclusion: { in: %w(customer employee manager), message: "%{value} no es un tipo válido"}

	def permissions=(val)
		case val
		when 'customer'
			self.can_clean = false
			self.can_detach = false
			self.can_set_temp = false
		when 'employee'
			self.can_clean = true
			self.can_detach = true
			self.can_set_temp = true
			self.category_id = nil
		when 'manager'
			self.can_clean = false
			self.can_detach = false
			self.can_set_temp = false
			self.category_id = nil
		end
		self.client_type = val
	end

	def client_type_human
		case client_type
		when 'customer'
			'Cliente'
		when 'employee'
			'Empleado'
		when 'manager'
			'Gerente'
		end
	end

	def current_tag
		tags.where(active: true).first
	end

	def add_tag(tag)
		if current_tag
			tag.credit += current_tag.credit 
			current_tag.update(active: false)
		end
		tag.active = true
		tag.save 
	end
end