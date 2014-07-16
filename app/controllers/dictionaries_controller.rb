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

		@num_lemmas = dictionary.lemmas.count

		@lang_lemmas = "Sanskrit?" # FIXME: extract lemmas lang
		@lang_definitions = "English?" #FIXME: extract defs lang
	end
end
