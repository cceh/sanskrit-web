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
		@query_engine = XPathQuery::Exist.new(@dict_db, :logger => Rails.logger)
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
		# FIXME: load only tei:form, not complete tei:(entry|re)
		tei_entries = all_entries.to_a

		entries = []

		tei_entries.each do |tei_entry|
			tei_orth = tei_entry.at("./tei:form/tei:orth", NS)
			tei_words = [tei_orth]

			transliterations = transliterations_for_words(tei_words)

			entries << {
				:entry => tei_entry,
				:transliterations => transliterations,
				:dict_handle => self.handle,
			}
		end

		return entries
	end

	def lemmas_count
		query = "count(#{DICT_ENTRIES})"
		count = xpathquery(query).first

		return count
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
		tei_words = tei_words_inside_tei_entry(tei_entry)

		transliterations = transliterations_for_words(tei_words)

		entry = {
			:entry => tei_entry,
			:transliterations => transliterations,
			:dict_handle => self.handle,
		}

		return entry
	end

	def transliterations_for_words(tei_words)
		transliterations = tei_words.map do |tei_word|
			word = tei_word.text # FIXME: include sub-tags?
			word.strip! # FIXME
			word.gsub!("\u221a", '!') # FIXME: deal with root char
			word.gsub!(/[0-9]/, '!') # FIXME: deal with digits

			raw_script = tei_word.attr('xml:lang')

			transliterations = transliterations_for_word(word, raw_script)

			next [word, transliterations_for_word(word, raw_script)]
		end

		return transliterations.to_h
	end

	def tei_words_inside_tei_entry(tei_entry)
		tei_words = tei_entry.xpath("./*[not(self::tei:re)]//*[self::tei:orth or self::tei:w or self::tei:m][@xml:lang = 'san-Latn-x-SLP1']", NS)
		return tei_words
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
			raise "Entry is stored in unknown script #{script.inspect}"
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

	def similar_matches_inside_definitions(term)
		# FIXME: use something better than "contains", like similar_matches
		query = "#{DICT_ENTRIES}[not(#{ORTH_EQUALS})][contains(string-join(./tei:sense//text()), '%{term}')]"
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
			language = xpathquery("string(#{DICT_ENTRIES}[1]/ancestor::*[@xml:lang]/@xml:lang)").first

			if language.nil? || language.empty?
				language = 'unk'
			end

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

# Licensed under the ISC licence, see LICENCE.ISC for details
