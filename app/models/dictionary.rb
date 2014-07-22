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
		# extract the top level <entry> or <re> elements
		entries = tei_entries.to_a.map { |tei_entry| entry_for_lemma(tei_entry) }
		return entries
	end

	def lemmas
		tei_entries = query_engine.all.to_a.uniq { |tei| tei.at('./tei:form/tei:orth', NS).text }

		entries = []

		tei_entries.each do |tei|
			transliterations = {
				:Deva => 'xxDEVAxx',
				:Latn_hk => 'xxLatn-HKxx',
			}

			entries << {
				:entry => tei,
				:transliterations => transliterations,
				:dict => self.handle,
			}
		end

		return entries
	end

	def lemma(id, script)
		query = "/tei:TEI/tei:text/tei:body//*[self::tei:entry | self::tei:re][@xml:id = 'lemma-#{id}']"

		results = query_engine.raw(query)
		if results.empty?
			raise "Lemma not found"
		end

		tei_entry = results.first
		entry = entry_for_lemma(tei_entry)

		return entry
	end

	def entry_for_lemma(tei_entry)
		tei_orth = tei_entry.at('./tei:form/tei:orth', NS)
		words = [tei_orth] # FIXME: search for words inside definitions

		transliterations = words.map do |tei_word|
			word = tei_word.text
			raw_script = tei_word.attr('xml:lang')
			transliterations = transliterations_for_word(word, raw_script)

			[word, transliterations_for_word(word, raw_script)]
		end.to_h

		entry = {
			:entry => tei_entry,
			:transliterations => transliterations,
			:dict_handle => self.handle,
		}

		return entry
	end

	def transliterations_for_word(word, script)
		case script
		when 'san-Latn-x-SLP1'
			native_script = word.transliterate(:Deva)
			return {
				'san-Deva' => native_script,
				'san-Latn-x-SLP1' => native_script.transliterate(:Latn, :method => :slp1),
				#'san-Latn-x-IAST' => native_script.transliterate(:Latn, :method => :iast),
			}
		else
			raise "Entry is stored in unknown script #{script}"
		end
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

	def default_language
		@default_language ||= lambda do
			ancestor = query_engine.raw("(//tei:re|//tei:entry)[1]/ancestor::*[@xml:lang]").first # FIXME

			language = ancestor.attr('xml:lang') unless ancestor.nil?
			language ||= 'unk'

			return language
		end.call

		return @default_language
	end

	def language_of_lemmas
		@language_of_lemmas ||= lambda do
			first_lemma = query_engine.first_entry

			language_attr = first_lemma.at('./tei:form/tei:orth/@xml:lang', NS) unless first_lemma.nil?
			language = language_attr.text unless language_attr.nil?
			language ||= self.default_language

			return language
		end.call

		return @language_of_lemmas
	end

	def language_of_definitions
		@language_of_definitions ||= lambda do
			first_lemma = query_engine.first_entry

			language_attr = first_lemma.at('./tei:sense/@xml:lang', NS) unless first_lemma.nil?
			language = language_attr.text unless language_attr.nil?
			language ||= self.default_language

			return language
		end.call

		return @language_of_definitions
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

		def first_entry
			query = "//*[#{IS_DICT_ENTRY}][1]"
			return @query_engine.query(query, NS).first
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
