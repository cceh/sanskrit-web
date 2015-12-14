require 'xpathquery/error'

class SearchController < ApplicationController
	before_action :fix_params, :only => :index
	before_action :default_params, :only => :index
	before_action :prepare_variables, :only => :index
	before_action :validate_params, :only => :index

	# GET /search
	def index
		has_search = !params[:q].nil?
		if !has_search
			return
		end

		@query = SearchController.query_from_params(params)

		term = @query[:term]
		ilanguages = @query[:ilanguages]
		itransliteration = @query[:itransliteration]
		dicts = @query[:dicts]
		where = @query[:where]
		how = @query[:how]

		@search_in_lemma = where.include? 'lemma'
		@search_in_definition = where.include? 'def'
		@exact_matches = how.include? 'exact'
		@partial_matches = how.include? 'partial'
		@similar_matches = how.include? 'similar'

		dicts.each do |dict_handle|
			begin
				dict = Dictionary.find_by! handle: dict_handle

				if @search_in_lemma && @exact_matches
					results = dict.exact_lemma_matches(term, ilanguages, itransliteration)
					@results[:exact_lemma][dict] = results
				end

				if @search_in_definition && @exact_matches
					results = dict.exact_definition_matches(term, ilanguages, itransliteration)
					@results[:exact_definition][dict] = results
				end

				if @search_in_lemma && @partial_matches
					results = dict.partial_lemma_matches(term, ilanguages, itransliteration)
					@results[:partial_lemma][dict] = results
				end

				if @search_in_definition && @partial_matches
					results = dict.partial_definition_matches(term, ilanguages, itransliteration)
					@results[:partial_definition][dict] = results
				end

				#similar_results = dict.similar_matches(term, ilanguage, itransliteration)
				#@results[:similar] += similar_results

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

	def self.query_from_params(params = nil)
		# FIXME: find a way to merge with default_params
		params ||= {
			:ilang => ['san', 'en', 'de'],
			:it13n => 'slp1',
			:dict => ['monier', 'pwg'],
			:where => [ 'lemma', 'def' ],
			:how => [ 'exact', 'partial', 'similar' ],
		}

		term = params[:q]
		ilanguages = param_ilanguage_to_value(params[:ilang])
		itransliteration = param_it13_to_value(params[:it13n])
		dicts = params[:dict]
		where = params[:where]
		how = params[:how]

		@query = {
			:term => term,
			:ilanguages => ilanguages,
			:itransliteration => itransliteration,
			:dicts => dicts,
			:where => where,
			:how => how,
		}
	end

	def prepare_variables
		@query = SearchController.query_from_params(params)

		@results = {
			:exact_lemma => {},
			:exact_definition => {},
			:partial_lemma => {},
			:partial_definition => {},

			:inside_defs => {},
			:similar => [],
			:preceding => {},
			:following => {},
		}
	end

	def default_params
		params[:ilang] ||= ['san', 'en', 'de']
		params[:it13n] ||= 'slp1'
		params[:dict] ||= ['monier', 'pwg'] # FIXME: use all dictionaries if no dict has been specified
		params[:where] ||= [ 'lemma', 'def' ]
		params[:how] ||= [ 'exact', 'partial', 'similar' ]
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

		# Use CGI parsing routine to allow ?how=exact&how=partial
		hows_in_query = CGI.parse(env['QUERY_STRING']||'')['how']
		params[:how] = hows_in_query unless hows_in_query.empty?

		if params[:where] == 'lemma-def'
			params[:where] = ['lemma', 'def']
		end
		params[:where] = Array(params[:where]) unless params[:where].nil?

		if params[:ilang] == 'any'
			params[:ilang] = nil
		end

		if !params[:ilang].nil?
			pieces = params[:ilang].split('-', 2)
			params[:ilang] = pieces[0]
			params[:it13n] = pieces[1]
		end
		params[:ilang] = Array(params[:ilang]) unless params[:ilang].nil?
	end

	LANGUAGE_ALIASES = {
		'eng' => 'en',
		'deu' => 'de',
		'ger' => 'de',
	}

	def self.param_ilanguage_to_value(param)
		languages = []

		param.each do |language|
			languages << language
			if LANGUAGE_ALIASES.has_key?(language)
				languages << LANGUAGE_ALIASES[language]
			end
		end

		return languages
	end

	def self.param_it13_to_value(param)
		value = param.to_sym

		if value == :iso
			value = :iso15919
		end

		return value
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
