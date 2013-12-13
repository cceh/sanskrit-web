require 'rest_client'
require 'nokogiri'

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
		tei_entries = raw_xml_matches(term)

		entries = tei_entries.map do |tei|
			lemma = "अंश्" # FIXME: replace with real entry
			transliterations = {
				:slp1 => "aMS",
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

	def raw_xml_matches(term)
		# FIXME: take dict handle into account

		dict = RestClient::Resource.new EXIST_REST_ENDPOINT

		query = query_xml_for_term(term)

		opts = {
			:content_type => 'application/xml'
		}

		begin
			response = dict.post(query, opts)
		rescue Exception => e
			raise DBError.new(dict, e)
		end

		# TODO: check for HTTP errors/status codes

		xml_response = Nokogiri::XML(response)
		tei_entries = xml_response.xpath('/exist:result/tei:entry', NS)

		return tei_entries
	end

	def query_xml_for_term(term)
		query =<<EOD
<query xmlns="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0">
	<text>//tei:entry[.//tei:orth = "#{term}"]</text>
</query>
EOD
		return query
	end
end
