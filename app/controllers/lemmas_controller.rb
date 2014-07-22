class LemmasController < ApplicationController
	# GET /dictionary/monier/lemmas
	def index
		dictionary = Dictionary.find_by_handle!(params[:dictionary_id])

		#@dict_handle = dictionary.handle
		@lemmas = dictionary.lemmas
	end

	# GET /dictionary/monier/lemma/aMSa?script=slp1
	def show
		script = params[:script]
		if !script.nil? && !script.empty? && script != 'slp1'
			raise "Unknown script #{script}"
		end

		dictionary = Dictionary.find_by_handle!(params[:dictionary_id])
		@lemma = dictionary.lemma(params[:id], script)
	end
end
