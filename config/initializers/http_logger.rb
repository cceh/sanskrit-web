if Rails.env == 'development'
	HttpLogger.log_headers = false  # Default: false
	HttpLogger.log_request_body  = false  # Default: true
	HttpLogger.log_response_body = false  # Default: true
end

# Licensed under the ISC licence, see LICENCE.ISC for details
