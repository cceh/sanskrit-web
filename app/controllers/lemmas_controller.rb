class LemmasController < ApplicationController
	# GET /dictionary/monier/lemmas
	def index
		dictionary = Dictionary.find_by_handle!(params[:dictionary_id])

		@dict = dictionary.publication_info
		@lemmas = dictionary.lemmas
	end

	# GET /dictionary/monier/lemma/aMSa?script=slp1
	def show
		script = params[:script]
		if !script.nil? && !script.empty? && script != 'slp1'
			raise "Unknown script #{script}"
		end

		entry_id = params[:id]

		dictionary = Dictionary.find_by_handle!(params[:dictionary_id])
		@lemma = dictionary.lemma(entry_id, script)

		@preceding_entries = dictionary.preceding_entries(entry_id)
		@following_entries = dictionary.following_entries(entry_id)
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
