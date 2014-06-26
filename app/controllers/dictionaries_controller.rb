class DictionariesController < ApplicationController
	# GET /dictionaries
	def index
		dictionaries = Dictionary.all
		dictionaries.map! { |dict| [dict.handle, dict.header] }

		@dictionaries = dictionaries.to_h
	end

	# GET /dictionary/monier
	def show
		dictionary = Dictionary.find_by_handle!(params[:id])

		@handle = dictionary.handle
		@header = dictionary.header
	end
end
