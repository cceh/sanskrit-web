require 't13n/core_ext/string'
require 'xpathquery'

class Dictionary < ActiveRecord::Base
	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db'

	NS = {
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	def matches(tei_entries)
		dict = 'monier' # FIXME: use content_path from DB

		entries = []

		# extract the top level <entry> or <re> elements
		tei_entries.each do |tei|
			raw_lemma = tei.at('./tei:form/tei:orth', NS).text

			lemma = raw_lemma.transliterate(:Deva)
			transliterations = {
				:slp1 => lemma.transliterate(:Latn, :method => :slp1)
			}
			# FIXME: make transliteration a dictionary from all the words present in the XML to all the  possible transliterations

			side_data = {
				:dict => dict,
				:lemma => lemma,
				:transliterations => transliterations,
			}

			entries << {
				:entry => tei,
				:side_data => side_data,
			}
		end

		return entries
	end

	def exact_matches(term)
		dict = 'monier' # FIXME: use content_path from DB
		return matches(DictQuery.new(dict).exact(term))
	end

	def similar_matches(term)
		dict = 'monier' # FIXME: use content_path from DB
		return matches(DictQuery.new(dict).similar(term))
	end

	def preceding_matches(term)
		dict = 'monier' # FIXME: use content_path from DB
		return matches(DictQuery.new(dict).preceding(term, 3)) # FIXME: make number configurable
	end

	def following_matches(term)
		dict = 'monier' # FIXME: use content_path from DB
		return matches(DictQuery.new(dict).following(term, 3)) # FIXME: make number configurable
	end

	class DictQuery
		IS_DICT_ENTRY = 'self::tei:entry or self::tei:re'
		ORTH_EQUALS = lambda { |term| "./tei:form/tei:orth/text() = '#{term}'" } # FIXME: escape parameters

		def initialize(dict)
			@dict = dict
			@dict_db = EXIST_REST_ENDPOINT + '/' + "dict/#{dict}.tei"
			@query_engine = XPathQuery::Exist.new(@dict_db, Rails.logger)
		end

		def exact(term)
			query = "//*[#{IS_DICT_ENTRY}][#{ORTH_EQUALS[term]}]"
			return @query_engine.query(query, NS)
		end

		def similar(term)
			query = "//*[#{IS_DICT_ENTRY}][contains(./tei:form/tei:orth/text(), '#{term}')][not(#{ORTH_EQUALS[term]})]"
			return @query_engine.query(query, NS)
		end

		def preceding(term, num)
			# FIXME: the order/position() is wrong, so the wrong set is returned
			query = "//*[#{IS_DICT_ENTRY}][#{ORTH_EQUALS[term]}]/preceding::*[#{IS_DICT_ENTRY}][position() <= #{num}]" # FIXME: escape parameters
			return @query_engine.query(query, NS)
		end

		def following(term, num)
			query = "//*[#{IS_DICT_ENTRY}][#{ORTH_EQUALS[term]}]/following::*[#{IS_DICT_ENTRY}][position() <= #{num}]" # FIXME: escape parameters
			return @query_engine.query(query, NS)
		end
	end
end
