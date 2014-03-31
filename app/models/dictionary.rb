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

	EXIST_REST_ENDPOINT = 'http://localhost:8080/exist/rest/db/dict'

	NS = {
		'exist' => 'http://exist.sourceforge.net/NS/exist',
		'tei' => 'http://www.tei-c.org/ns/1.0',
	}

	def matches(term)
		query_exact = DictQuery.exact(term)
		tei_entries = query_exact.results_xml

		entries = tei_entries.map do |tei|
			raw_lemma = tei.at('.//tei:orth', NS).text
			lemma = raw_lemma.transliterate(:Deva)
			transliterations = {
				:slp1 => lemma.transliterate(:Latn, :method => :slp1)
			}
			senses = tei.xpath('.//tei:sense', NS).map(&:text)
			image_refs = []

			{
				:lemma => lemma,
				:transliterations => transliterations,
				:senses => senses,
				:image_refs => image_refs,
			}
		end

		return entries
	end

	class DictQuery
		def self.exact(term)
			query = "//tei:entry[.//tei:orth[. = '#{term}']]" # FIXME: escape parameters
			qe = XQueryExecutor.new('monier.tei', query) # FIXME: take dict handle into account

			return qe
		end

		def self.similar(term)
			# TODO: implement search for "similar" terms

			# xpath = "//tei:entry[.//tei:orth[contains(., '#{term}')]]"

			return nil
		end

		def self.related(term)
			# TODO: implement search for "related" terms
		end
	end

	class XQueryExecutor
		def initialize(dict, query)
			@dict = dict
			@query = query
		end

		def results_xml
			dict_url = EXIST_REST_ENDPOINT + '/' + @dict
			dict = RestClient::Resource.new dict_url

			query_message = query_message(@query)

			opts = {
				:content_type => 'application/xml'
			}

			begin
				response = dict.post(query_message, opts)
			rescue Exception => e
				raise DBError.new(dict, e)
			end

			# TODO: check for HTTP errors/status codes

			xml_response = Nokogiri::XML(response)
			if xml_response.root.name == 'exception'
				raise DBError.new(dict, xml_response.xpath('//message')[0].text())
			end
			tei_entries = xml_response.xpath('/exist:result/tei:entry', NS)

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
