require 'xpathquery/error'

class SearchController < ApplicationController
	before_action :fix_params, :only => :index
	before_action :default_params, :only => :index
	before_action :validate_params, :only => :index

	# GET /search
	def index
		@query = {}
		@results = {
			:exact => {},
			:similar => [],
			:preceding => {},
			:following => {},
		}

		has_search = !params[:q].nil?
		if !has_search
			return
		end

		term = params[:q]
		language = params[:ilang] # TODO: transliterate if needed
		dicts = params[:dict]
		where = params[:where]

		@query = {
			:term => term,
			:ilang => language,
			:dicts => dicts,
			:where => where,
		}

		flash.now[:error] ||= []
		flash.now[:query] ||= []
		flash.now[:response] ||= []
		flash.now[:cause] ||= []

		dicts.each do |dict_handle|
			begin
				dict = Dictionary.find_by! handle: dict_handle

				exact_results = dict.exact_matches(term)
				@results[:exact][dict] = exact_results

				similar_results = dict.similar_matches(term)
				@results[:similar] += similar_results

				preceding_results = dict.preceding_matches(term)
				@results[:preceding][dict] = preceding_results

				following_results = dict.following_matches(term)
				@results[:following][dict] = following_results
			rescue XPathQuery::Error => ex
				flash.now[:error] << ex.message
				flash.now[:query] << ex.query
				flash.now[:response] << ex.response
				flash.now[:cause] << ex.cause.inspect

				next
			rescue T13n::Error => ex
				flash.now[:error] << "(in #{dict_handle}) " + ex.message
				flash.now[:cause] << ex.cause.inspect

				next
			end
		end
	end

	def default_params
		if !params[:q]
			return
		end

		params[:ilang] ||= 'slp1'
		params[:dict] ||= ['monier'] # FIXME: use all dictionaries if no dict has been specified
		params[:where] ||= 'both'
	end

	def validate_params
		# TODO: raise if problems detected
	end

	def fix_params
		if params[:dict] == 'all'
			params[:dict] = nil
		end

		params[:ilang].sub!('san-', '') unless params[:ilang].nil?
	end
end
