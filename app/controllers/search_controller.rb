require 'xpathquery/error'

class SearchController < ApplicationController
	before_action :prepare_variables, :only => :index
	before_action :fix_params, :only => :index
	before_action :default_params, :only => :index
	before_action :validate_params, :only => :index

	# GET /search
	def index
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

		@search_in_lemma = where.include? 'lemma'
		@search_in_definitions = where.include? 'def'

		dicts.each do |dict_handle|
			begin
				dict = Dictionary.find_by! handle: dict_handle

				if @search_in_lemma
					exact_results = dict.exact_matches(term)
					@results[:exact][dict] = exact_results
				end

				if @search_in_definitions
					inside_defs = dict.similar_matches_inside_definitions(term)
					@results[:inside_defs][dict] = inside_defs
				end

				similar_results = dict.similar_matches(term)
				@results[:similar] += similar_results

				#preceding_results = dict.preceding_matches(term)
				#@results[:preceding][dict] = preceding_results

				#following_results = dict.following_matches(term)
				#@results[:following][dict] = following_results
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

	def prepare_variables
		@query = {}

		@results = {
			:exact => {},
			:inside_defs => {},
			:similar => [],
			:preceding => {},
			:following => {},
		}

		flash.now[:error] ||= []
		flash.now[:query] ||= []
		flash.now[:response] ||= []
		flash.now[:cause] ||= []
	end

	def default_params
		params[:ilang] ||= 'slp1'
		params[:dict] ||= ['monier', 'pwg'] # FIXME: use all dictionaries if no dict has been specified
		params[:where] ||= [ 'lemma', 'def' ]
	end

	def validate_params
		# TODO: raise if problems detected
		if !params[:q] || params[:q].empty?
			flash.now[:error] << "Please specify a query"
		end

		if !flash.now[:error].empty?
			render
		end
	end

	def fix_params
		if params[:dict] == 'all'
			params[:dict] = nil
		end

		if params[:where] == 'lemma-def'
			params[:where] = ['lemma', 'def']
		end
		params[:where] = Array(params[:where]) unless params[:where].nil?

		params[:ilang].sub!('san-', '') unless params[:ilang].nil?
	end
end
