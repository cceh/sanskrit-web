class ScansController < ApplicationController
	# GET /dictionary/monier/scans
	def index
		dictionary = Dictionary.find_by_handle! params[:dictionary_id]

		@dict = dictionary.publication_info
		@scans = dictionary.scans
	end

	# GET /dictionary/monier/scans/0001
	def show
		dictionary = Dictionary.find_by_handle! params[:dictionary_id]
		scan_handle = "page-#{params[:id]}"

		@dict = dictionary.publication_info
		dict_handle = @dict[:handle]
		@dict_header = dictionary.header

		@scan = dictionary.scan(scan_handle)

		if @scan.nil?
			raise ActiveRecord::RecordNotFound
		end

		@best_format = [:jpeg, :png].find { |format| File.exist?(file_for_scan(dict_handle, @scan, format)) }

		@prev_scan = dictionary.preceding_scan(scan_handle)
		@next_scan = dictionary.following_scan(scan_handle)

		respond_to do |format|
			format.html
			format.jpeg { send_file file_for_scan(dict_handle, @scan, :jpeg), type: 'image/jpeg', disposition: 'inline' }
			format.png { send_file file_for_scan(dict_handle, @scan, :png), type: 'image/png', disposition: 'inline' }
		end
	end

	private

	def file_for_scan(dict, scan, format)
		filename = scan.attribute('url').text.split('/').last
		return Rails.root + "../sanskrit-dicts/#{dict}/scans/#{format}/#{filename}.#{format}"
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
