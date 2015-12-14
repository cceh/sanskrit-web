class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_action :prepare_flash

	def prepare_flash
		flash.now[:error] ||= []
		flash.now[:query] ||= []
		flash.now[:response] ||= []
		flash.now[:cause] ||= []
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
