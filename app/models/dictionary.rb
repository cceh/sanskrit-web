require 'nokogiri'
require 'rest_client'
require 't13n/core_ext/string'

class Dictionary < ActiveRecord::Base
	class DBError < Exception
		def initialize(connection, error)
			@connection = connection
			@error = error
		end

		def message
			"Cannot connect to <#{@connection.url}>, #{@error}"
		end
	end

	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db'

	NS = {
		'exist' => 'http://exist.sourceforge.net/NS/exist',
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	def exact_matches(term)
		query_exact = DictQuery.new('monier').exact(term) # FIXME: use dict code
		tei_entries = query_exact.results_xml

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

	class DictQuery
		def initialize(dict)
			@dict = dict
			@dict_db = "dict/#{dict}.tei"
		end

		def exact(term)
			query = "//*[self::tei:entry or self::tei:re][./tei:form/tei:orth/text() = '#{term}']" # FIXME: escape parameters
			qe = XQueryExecutor.new(@dict_db, query)

			return qe
		end

		def similar(term)
			# TODO: implement search for "similar" terms

			# xpath = "//tei:entry[.//tei:orth[contains(., '#{term}')]]"

			return nil
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
				raise DBError.new(dict, e)
			end

			Rails.logger.debug "received XML response\n#{response}"
			# TODO: check for HTTP errors/status codes

			xml_response = Nokogiri::XML(response)
			if xml_response.root.name == 'exception'
				raise DBError.new(dict, xml_response.xpath('//message')[0].text())
			end
			tei_entries = xml_response.xpath('/exist:result/tei:*', NS)

			return tei_entries
		end

		def query_message(query)
			message =<<EOD
<query xmlns="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0">
	<text>#{query}</text>
</query>
EOD
			return message
		end
	end
end
