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
		ilanguage = params[:ilang]
		itransliteration = params[:it13n].to_sym
		dicts = params[:dict]
		where = params[:where]

		@query = {
			:term => term,
			:ilanguage => ilanguage,
			:transliteration => itransliteration,
			:dicts => dicts,
			:where => where,
		}

		@search_in_lemma = where.include? 'lemma'
		@search_in_definitions = where.include? 'def'

		dicts.each do |dict_handle|
			begin
				dict = Dictionary.find_by! handle: dict_handle

				if @search_in_lemma
					exact_results = dict.exact_matches(term, ilanguage, itransliteration)
					@results[:exact][dict] = exact_results
				end

				if @search_in_definitions
					inside_defs = dict.similar_matches_inside_definitions(term, ilanguage, itransliteration)
					@results[:inside_defs][dict] = inside_defs
				end

				similar_results = dict.similar_matches(term, ilanguage, itransliteration)
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
		params[:ilang] ||= 'san'
		params[:it13n] ||= 'slp1'
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
		# Use CGI parsing routine to allow ?dict=foo&dict=bar
		dicts_in_query = CGI.parse(env['QUERY_STRING']||'')['dict']
		params[:dict] = dicts_in_query unless dicts_in_query.empty?

		if params[:dict] == ['all']
			params[:dict] = nil
		end

		if params[:where] == 'lemma-def'
			params[:where] = ['lemma', 'def']
		end
		params[:where] = Array(params[:where]) unless params[:where].nil?

		if !params[:ilang].nil?
			pieces = params[:ilang].split('-', 2)
			params[:ilang] = pieces[0]
			params[:it13n] = pieces[1]
		end
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
