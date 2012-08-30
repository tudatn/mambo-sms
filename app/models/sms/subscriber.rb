module Sms
	class Subscriber < ActiveRecord::Base
		# attributes
		attr_accessible(:active, :phone_number)

		# validations
		validates(:active, :inclusion => {:in => [true, false]})
		validates(:phone_number, {:uniqueness => true, :presence => true, :length => {:is => PHONE_NUMBER_LENGTH}, :format => /^\d*$/})

		# associations
		has_many(:messages, :dependent => :destroy)

		# instance methods
		#
		def disable
			update(:active => false)
		end

		#
		def enable
			update(:active => true)
		end

		#
		def receive_message(from, body, sid, created_at = nil)
			messages.create(
				:phone_number => phone_number,
				:body => body,
				:status => :received,
				:sid => sid,
				:created_at => created_at
			)
		end

		#
		def send_message_using_template(name, params = {})
			message_template = MessageTemplate.get_by_name(name)
			messages.create(
				:phone_number => phone_number,
				:body => message_template.body % params,
				:status => :sending
			)
		end

		#
		def send_message(body)
			messages.create(
				:phone_number => phone_number,
				:body => body,
				:status => :sending
			)
		end

		# class methods
		def self.active
			where(:active => true)
		end

		#
		def self.first_by_phone_number(phone_number)
			first(:phone_number => phone_number)
		end

		#
		def self.create_for(phone_number)
			create(:phone_number => phone_number)
		end
	end
end

