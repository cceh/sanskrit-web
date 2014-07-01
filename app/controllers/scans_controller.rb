class ScansController < ApplicationController
	# GET /dictionary/monier/scans
	def index
		dictionary = Dictionary.find_by_handle! params[:dictionary_id]

		@dict_handle = dictionary.handle
		@scans = dictionary.scans
	end

	# GET /dictionary/monier/scans/0001
	def show
		dictionary = Dictionary.find_by_handle! params[:dictionary_id]
		scan_handle = "page-#{params[:id]}"

		@dict_handle = dictionary.handle
		@dict_header = dictionary.header

		@scan = dictionary.scan(scan_handle)

		if @scan.nil?
			raise ActiveRecord::RecordNotFound
		end

		@prev_scan = dictionary.preceding_scan(scan_handle)
		@next_scan = dictionary.following_scan(scan_handle)

		respond_to do |format|
			format.html
			format.jpeg { send_file jpeg_for_scan(@dict_handle, @scan), type: 'image/jpeg', disposition: 'inline' }
		end
	end

	private

	def jpeg_for_scan(dict, scan)
		filename = scan.attribute('url').text.split('/').last
		return Rails.root + "../sanskrit-dicts/#{dict}/scans/jpeg/#{filename}.jpeg"
	end
end
