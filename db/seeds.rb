dict_handles = [
	'monier',
	'pwg',
	'aptestud',
]

dict_handles.each do |handle|
	Dictionary.create(handle: handle,
			  metadata_path: "#{handle}.metadata.xml",
			  content_path: "#{handle}.tei")
end

# Licensed under the ISC licence, see LICENCE.ISC for details
