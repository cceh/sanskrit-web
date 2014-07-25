require 't13n/core_ext/string'
require 'xpathquery'

class Dictionary < ActiveRecord::Base
	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db'

	IS_DICT_ENTRY = 'self::tei:entry or self::tei:re'
	ORTH_EQUALS = './tei:form/tei:orth/text() = "%{term}"' # FIXME: escape parameters

	DICT_ENTRIES = "/tei:TEI/tei:text/tei:body//*[#{IS_DICT_ENTRY}]"
	DICT_SCANS = '/tei:TEI/tei:facsimile/tei:graphic'

	NS = {
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	after_initialize :setup_query_engine

	def setup_query_engine
		dict_path = self.content_path
		@dict_db = EXIST_REST_ENDPOINT + '/' + "dict/#{dict_path}"
		@query_engine = XPathQuery::Exist.new(@dict_db, Rails.logger)
	end

	def xpathquery(query, params = {})
		@query_engine.query(query, params, NS)
	end

	def header
		return xpathquery('/tei:TEI/tei:teiHeader').first
	end

	def matches(tei_entries)
		# extract the top level <entry> or <re> elements
		entries = tei_entries.to_a.map { |tei_entry| entry_for_lemma(tei_entry) }
		return entries
	end

	def lemmas
		tei_entries = all_entries.to_a.uniq { |tei| tei.at('./tei:form/tei:orth', NS).text }

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
		query = "#{DICT_ENTRIES}[@xml:id = 'lemma-%{id}']"
		params = { :id => id }

		results = xpathquery(query, params)
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

	def exact_matches(term)
		query = "#{DICT_ENTRIES}[#{ORTH_EQUALS}]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def similar_matches(term)
		# FIXME: use something better than "contains"
		query = "#{DICT_ENTRIES}[contains(./tei:form/tei:orth/text(), '%{term}')][not(#{ORTH_EQUALS})]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def preceding_matches(term)
		num = 3 # FIXME: make number configurable

		# FIXME: the order/position() may be wrong, check that the correct set is returned
		query = "#{DICT_ENTRIES}[#{ORTH_EQUALS}]/preceding::*[#{IS_DICT_ENTRY}][position() <= %{num}]" # FIXME: escape parameters
		params = { :term => term, :num => num }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def following_matches(term)
		num = 3 # FIXME: make number configurable

		query = "#{DICT_ENTRIES}[#{ORTH_EQUALS}]/following::*[#{IS_DICT_ENTRY}][position() <= %{num}]" # FIXME: escape parameters
		params = { :term => term, :num => num }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def scans
		query = DICT_SCANS
		return xpathquery(query)
	end

	def scan(scan_handle)
		query = "#{DICT_SCANS}[@xml:id = '%{scan_handle}']"
		params = { :scan_handle => scan_handle }

		return xpathquery(query, params).first
	end

	def preceding_scan(scan_handle)
		query = "#{DICT_SCANS}[@xml:id = '%{scan_handle}']/preceding-sibling::tei:graphic[1]"
		params = { :scan_handle => scan_handle }

		return xpathquery(query, params).first
	end

	def following_scan(scan_handle)
		query = "#{DICT_SCANS}[@xml:id = '%{scan_handle}']/following-sibling::tei:graphic[1]"
		params = { :scan_handle => scan_handle }

		return xpathquery(query, params).first
	end

	def default_language
		@default_language ||= lambda do
			ancestor = xpathquery("(//tei:re|//tei:entry)[1]/ancestor::*[@xml:lang]").first # FIXME

			language = ancestor.attr('xml:lang') unless ancestor.nil?
			language ||= 'unk'

			return language
		end.call

		return @default_language
	end

	def language_of_lemmas
		@language_of_lemmas ||= lambda do
			first_lemma = first_entry

			language_attr = first_lemma.at('./tei:form/tei:orth/@xml:lang', NS) unless first_lemma.nil?
			language = language_attr.text unless language_attr.nil?
			language ||= self.default_language

			return language
		end.call

		return @language_of_lemmas
	end

	def language_of_definitions
		@language_of_definitions ||= lambda do
			first_lemma = first_entry

			language_attr = first_lemma.at('./tei:sense/@xml:lang', NS) unless first_lemma.nil?
			language = language_attr.text unless language_attr.nil?
			language ||= self.default_language

			return language
		end.call

		return @language_of_definitions
	end


	def all_entries
		query = DICT_ENTRIES
		return xpathquery(query)
	end

	def first_entry
		query = "#{DICT_ENTRIES}[1]"
		return xpathquery(query).first
	end
end
