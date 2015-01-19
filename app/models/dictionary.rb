require 't13n/core_ext/string'
require 'xpathquery/basex'

class Dictionary < ActiveRecord::Base
	BASEX_REST_ENDPOINT = 'http://localhost:8984/rest'

	ENTRY_ID_EQUALS = '@xml:id = "lemma-%{entry_id}"'
	IS_DICT_ENTRY = 'self::tei:entry or self::tei:re'
	ORTH_EQUALS = './tei:form/tei:orth[. = "%{term}"]' # FIXME: escape parameters
	ORTH_CONTAINS = './tei:form/tei:orth[contains(., "%{term}")]' # FIXME: escape parameters
	IN_LANGUAGE = 'ancestor-or-self::*[@xml:lang][1]'
	LANGUAGE_CLASS = 'starts-with(@xml:lang, "LANGUAGE")'
	LANGUAGE_EXACT = '@xml:lang = "LANGUAGE"'

	DICT_ENTRIES = "/tei:TEI/tei:text/tei:body//*[#{IS_DICT_ENTRY}]"
	DICT_SCANS = '/tei:TEI/tei:facsimile/tei:graphic'

	NS = {
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	after_initialize :setup_query_engine

	def setup_query_engine
		dict_path = self.content_path
		@dict_db = BASEX_REST_ENDPOINT + "/#{dict_path}"
		@query_engine = XPathQuery::BaseX.new(@dict_db, :logger => Rails.logger)
	end

	def xpathquery(query, params = {})
		@query_engine.query(query, params, NS)
	end

	def header
		# FIXME: declare stale after X seconds and compare cache
		@header ||= xpathquery('/tei:TEI/tei:teiHeader').first
		return @header
	end

	def header_item(id)
		# FIXME: merge with backmatter_item
		header_complete = header
		if !header_complete.is_a? Nokogiri::XML::Element
			return []
		end

		return header_complete.xpath("//*[@xml:id = '#{id}']", NS)
	end

	def backmatter
		# FIXME: use a common cache system with `header`
		@backmatter ||= xpathquery('/tei:TEI/tei:text/tei:back').first
		return @backmatter
	end

	def backmatter_item(id)
		backmatter_complete = backmatter
		if !backmatter_complete.is_a? Nokogiri::XML::Element
			return []
		end

		return backmatter_complete.xpath("//*[@xml:id = '#{id}']", NS)
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
				:dict => publication_info,
			}
		end

		return entries
	end

	def lemmas_count
		query = "count(#{DICT_ENTRIES})"
		count = xpathquery(query).first.to_i

		return count
	end

	def lemma(entry_id, script)
		query = "#{DICT_ENTRIES}[#{ENTRY_ID_EQUALS}]"
		params = { :entry_id => entry_id }

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

		tei_refs = tei_refs_inside_tei_entry(tei_entry)
		references = references_for_refs(tei_refs)

		entry = {
			:entry => tei_entry,
			:transliterations => transliterations,
			:references => references,
			:dict => publication_info,
		}

		return entry
	end

	def transliterations_for_words(tei_words)
		transliterations = tei_words.map do |tei_word|
			word = tei_word.text # FIXME: include sub-tags?
			word.strip! # FIXME
			word.gsub!("\u221a", '!') # FIXME: deal with root char
			word.gsub!(/[0-9]/, '!') # FIXME: deal with digits

			raw_lang = tei_word.attr('xml:lang')

			transliterations = transliterations_for_word(word, raw_lang)

			next [word, transliterations_for_word(word, raw_lang)]
		end

		return transliterations.to_h
	end

	def tei_words_inside_tei_entry(tei_entry)
		tei_words = tei_entry.xpath("./*[not(self::tei:re)]//*[self::tei:orth or self::tei:hyph or self::tei:w or self::tei:m][(@xml:lang = 'san-Latn-x-SLP1') or (@xml:lang = 'san-Latn-x-SLP1-headword2')]", NS)
		tei_words = tei_words.to_a.reject { |w| w.text.blank? }
		return tei_words
	end

	def transliterations_for_word(word, lang_tag)
		mETHOD_FOR_LANG = {
			'san-Latn-x-SLP1' => :slp1,
			'san-Latn-x-SLP1-headword2' => :slp1_headword2
		}

		method = mETHOD_FOR_LANG[lang_tag]

		case lang_tag
		when 'san-Latn-x-SLP1', 'san-Latn-x-SLP1-headword2'
			native_script = word.transliterate(:Deva, :method => method)

			# TODO: only generate the needed transliterations
			transliterations = {
				'san-Deva' => native_script,
				'san-Latn-x-SLP1' => native_script.transliterate(:Latn, :method => :slp1),
				'san-Latn-x-ISO15919' => native_script.transliterate(:Latn, :method => :iso15919),
			}

			return transliterations
		else
			raise "Entry is stored in unknown language #{lang_tag.inspect}"
		end
	end

	def tei_refs_inside_tei_entry(tei_entry)
		tei_refs = tei_entry.xpath('.//tei:ref', NS)
		tei_refs += tei_entry.xpath('.//tei:g[@ref]', NS)
		return tei_refs
	end

	def references_for_refs(tei_refs)
		targets = tei_refs.map { |tei_ref| tei_ref.attr('target') || tei_ref.attr('ref') || '##none' }
		ids = targets.map { |target| target.sub('#', '') }.uniq

		references = {}
		ids.each do |id|
			item = backmatter_item(id).first
			item ||= header_item(id).first
			references[id] = item unless item.nil?

			nested_ref = item.at('.//tei:ref', NS) unless item.nil?
			if !nested_ref.nil?
				nested_id = nested_ref.attr('target').sub('#', '')
				nested_item = backmatter_item(nested_id)
				references[nested_id] = nested_item unless nested_item.nil?
			end
		end

		return references
	end

	def normalized_term(term, transliteration)
		dictionary_transliteration = :slp1 # FIXME: make per dict

		if dictionary_transliteration == transliteration
			normalized = term
		else
			if transliteration == :devanagari
				deva = term
			else
				deva = term.transliterate(:Deva, :method => transliteration)
			end

			normalized = deva.transliterate(:Latn, :method => dictionary_transliteration)
		end

		return normalized
	end

	def language_xpath_matcher(ter, languages)
		language_matches = languages.map do |language|
			if language == 'san' # FIXME: language_has_many_transliterations(language)
				language_matcher = LANGUAGE_CLASS
			else
				language_matcher = LANGUAGE_EXACT
			end
			language_matcher.sub("LANGUAGE", language)
		end

		language_match = language_matches.map {|m| "(#{m})" }.join(" or ")
		matcher = "#{IN_LANGUAGE}[#{language_match}]"

		return matcher
	end

	def exact_lemma_matches(term, languages, transliteration)
		matches = []

		matches += exact_lemma_matches_san(term, transliteration) if languages.include?('san')

		other_languages = languages.reject { |lang| lang == 'san' }
		matches += exact_lemma_matches_generic(term, other_languages) unless other_languages.empty?

		return matches
	end

	def exact_lemma_matches_san(term, transliteration)
		normalized = normalized_term(term, transliteration)

		return exact_lemma_matches_generic(normalized, ['san'])
	end

	def exact_lemma_matches_generic(term, languages)
		languages_xpath = language_xpath_matcher(term, languages)
		query = "#{DICT_ENTRIES}[#{ORTH_EQUALS}[#{languages_xpath}]]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def exact_definition_matches(term, languages, transliteration)
		matches = []

		matches += exact_definition_matches_san(term, transliteration) if languages.include?('san')

		other_languages = languages.reject { |lang| lang == 'san' }
		matches += exact_definition_matches_generic(term, other_languages) unless other_languages.empty?

		return matches
	end

	def exact_definition_matches_san(term, transliteration)
		normalized = normalized_term(term, transliteration)

		return exact_definition_matches_generic(normalized, ['san'])
	end

	def exact_definition_matches_generic(term, languages)
		languages_xpath = language_xpath_matcher(term, languages)
		query = "#{DICT_ENTRIES}[./tei:sense//text()[(normalize-space() = '%{term}') or contains(., ' %{term} ') or contains(., ' %{term}.') or contains(., ' %{term},')][#{languages_xpath}]]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def partial_lemma_matches(term, languages, transliteration)
		matches = []

		matches += partial_lemma_matches_san(term, transliteration) if languages.include?('san')

		other_languages = languages.reject { |lang| lang == 'san' }
		matches += partial_lemma_matches_generic(term, other_languages) unless other_languages.empty?

		return matches
	end

	def partial_lemma_matches_san(term, transliteration)
		normalized = normalized_term(term, transliteration)

		return partial_lemma_matches_generic(normalized, ['san'])
	end

	def partial_lemma_matches_generic(term, languages)
		languages_xpath = language_xpath_matcher(term, languages)

		query = "#{DICT_ENTRIES}[#{ORTH_CONTAINS}[#{languages_xpath}]]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def partial_definition_matches(term, languages, transliteration)
		matches = []

		matches += partial_definition_matches_san(term, transliteration) if languages.include?('san')

		other_languages = languages.reject { |lang| lang == 'san' }
		matches += partial_definition_matches_generic(term, other_languages) unless other_languages.empty?

		return matches
	end

	def partial_definition_matches_san(term, transliteration)
		normalized = normalized_term(term, transliteration)

		return partial_definition_matches_generic(normalized, ['san'])
	end

	def partial_definition_matches_generic(term, languages)
		languages_xpath = language_xpath_matcher(term, languages)

		query = "#{DICT_ENTRIES}[./tei:sense//text()[contains(., '%{term}')][#{languages_xpath}]]"
		params = { :term => term }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def similar_matches(term, language, transliteration)
		# FIXME: use something better than "contains"
		query = "#{DICT_ENTRIES}[contains(./tei:form/tei:orth/text(), '%{term}')][not(#{ORTH_EQUALS})]"
		params = { :term => normalized_term(term, language, transliteration) }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def similar_matches_inside_definitions(term, language, transliteration)
		# FIXME: use something better than "contains", like similar_matches
		query = "#{DICT_ENTRIES}[not(#{ORTH_EQUALS})][contains(string-join(./tei:sense//text()), '%{term}')]"
		params = { :term => normalized_term(term, language, transliteration) }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def preceding_entries(entry_id)
		num = 3 # FIXME: make number configurable

		# FIXME: the order/position() may be wrong, check that the correct set is returned
		query = "#{DICT_ENTRIES}[#{ENTRY_ID_EQUALS}]/preceding::*[#{IS_DICT_ENTRY}][position() <= %{num}]" # FIXME: escape parameters
		params = { :entry_id => entry_id, :num => num }

		tei_matches = xpathquery(query, params)

		return matches(tei_matches)
	end

	def following_entries(entry_id)
		num = 3 # FIXME: make number configurable

		query = "#{DICT_ENTRIES}[#{ENTRY_ID_EQUALS}]/following::*[#{IS_DICT_ENTRY}][position() <= %{num}]" # FIXME: escape parameters
		params = { :entry_id => entry_id, :num => num }

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

	def publication_info
		h = self.header

		common_title = h.at('//tei:titleStmt//tei:title[@type="desc"]', NS).text
		orig_title = h.at('//tei:sourceDesc//tei:title[@type="main"]', NS).text
		tei_subtitle = h.at('//tei:sourceDesc//tei:title[@type="sub"]', NS)
		orig_subtitle = tei_subtitle.text unless tei_subtitle.nil?
		orig_author = h.at('//tei:sourceDesc//tei:author[1]', NS).text
		orig_date = 2099 # FIXME: extract orig_date

		dict = {
			:handle => self.handle,
			:common_title => common_title,
			:orig_title => orig_title,
			:orig_subtitle => orig_subtitle,
			:orig_author => orig_author,
			:orig_date => orig_date,
		}

		return dict
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
