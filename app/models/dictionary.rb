require 't13n/core_ext/string'
require 'xpathquery'

class Dictionary < ActiveRecord::Base
	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db'

	NS = {
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	def header
		return query_engine.raw('/tei:TEI/tei:teiHeader').first
	end

	def matches(tei_entries)
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
				:dict => self.handle,
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

	def query_engine
		@query_engine ||= DictQuery.new(self.content_path)
		return @query_engine
	end

	def exact_matches(term)
		return matches(query_engine.exact(term))
	end

	def similar_matches(term)
		return matches(query_engine.similar(term))
	end

	def preceding_matches(term)
		return matches(query_engine.preceding(term, 3)) # FIXME: make number configurable
	end

	def following_matches(term)
		return matches(query_engine.following(term, 3)) # FIXME: make number configurable
	end

	def scans
		query = "/tei:TEI/tei:facsimile/tei:graphic"
		return query_engine.raw(query)
	end

	def scan(scan_handle)
		query = "/tei:TEI/tei:facsimile/tei:graphic[@xml:id = '#{scan_handle}']"
		return query_engine.raw(query).first
	end

	def preceding_scan(scan_handle)
		query = "/tei:TEI/tei:facsimile/tei:graphic[@xml:id = '#{scan_handle}']/preceding-sibling::tei:graphic[1]"
		return query_engine.raw(query).first
	end

	def following_scan(scan_handle)
		query = "/tei:TEI/tei:facsimile/tei:graphic[@xml:id = '#{scan_handle}']/following-sibling::tei:graphic[1]"
		return query_engine.raw(query).first
	end

	def lemmas
		query_engine.all
	end

	class DictQuery
		IS_DICT_ENTRY = 'self::tei:entry or self::tei:re'
		ORTH_EQUALS = lambda { |term| "./tei:form/tei:orth/text() = '#{term}'" } # FIXME: escape parameters

		def initialize(dict_path)
			@dict_path = dict_path
			@dict_db = EXIST_REST_ENDPOINT + '/' + "dict/#{dict_path}"
			@query_engine = XPathQuery::Exist.new(@dict_db, Rails.logger)
		end

		def raw(query)
			return @query_engine.query(query, NS)
		end

		def all
			query = "//*[#{IS_DICT_ENTRY}]"
			return @query_engine.query(query, NS)
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
