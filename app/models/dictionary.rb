require 'nokogiri'
require 'rest_client'
require 't13n/core_ext/string'

class Dictionary < ActiveRecord::Base
	class DBError < Exception
		def initialize(connection, query, error)
			@connection = connection
			@query = query
			@error = error
		end

		def message
			# XXX: maybe move the query to an accessor method?
			"Cannot connect to <#{@connection.url}>, #{@error} (query: #{@query})"
		end
	end

	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db'

	NS = {
		'exist' => 'http://exist.sourceforge.net/NS/exist',
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	def matches(query)
		dict = 'monier' # FIXME: use content_path from DB

		tei_entries = query.results_xml

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

	class DictQuery
		IS_DICT_ENTRY = 'self::tei:entry or self::tei:re'

		def initialize(dict)
			@dict = dict
			@dict_db = "dict/#{dict}.tei"
		end

		def exact(term)
			query = "//*[#{IS_DICT_ENTRY}][./tei:form/tei:orth/text() = '#{term}']" # FIXME: escape parameters
			qe = XQueryExecutor.new(@dict_db, query)

			return qe
		end

		def similar(term)
			query = "//*[#{IS_DICT_ENTRY}][contains(./tei:form/tei:orth/text(), '#{term}')][./tei:form/tei:orth/text() != '#{term}']" # FIXME: escape parameters
			qe = XQueryExecutor.new(@dict_db, query)

			return qe
		end

		def related(term)
			# TODO: implement search for "related" terms
		end
	end

	class XQueryExecutor
		def initialize(dict_db, query)
			@dict_db = dict_db
			@query = query
		end

		def results_xml
			dict_url = EXIST_REST_ENDPOINT + '/' + @dict_db
			dict = RestClient::Resource.new dict_url

			query_message = query_message(@query)
			Rails.logger.debug "about to run on #{dict_url} the query\n#{query_message}"

			opts = {
				:content_type => 'application/xml'
			}

			begin
				response = dict.post(query_message, opts)
			rescue Exception => e
				raise DBError.new(dict, @query, e)
			end

			Rails.logger.debug "received XML response\n#{response}"
			# TODO: check for HTTP errors/status codes

			xml_response = Nokogiri::XML(response)
			if xml_response.root.name == 'exception'
				raise DBError.new(dict, @query, xml_response.xpath('//message')[0].text())
			end
			tei_entries = xml_response.xpath('/exist:result/tei:*', NS)

			return tei_entries
		end

		def query_message(query)
			# FIXME: sanitize query parameters
			message =<<EOD
<query xmlns="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0">
	<text>#{query.gsub('&', '&amp;').gsub('<', '&lt;')}</text>
</query>
EOD
			return message
		end
	end
end
