module SearchHelper
	# FIXME: remove this method once we have a rails-xslt gem
	def simple_xmlify(v)
		case v
		when Hash
			v.map{|key, val|
				"<#{CGI::escapeHTML(key.to_s)}>#{simple_xmlify(val)}</#{CGI::escapeHTML(key.to_s)}>"
			}.join("")
		when Array
			r = []
			v.each_index do |i|
				r << "<val>#{simple_xmlify(v[i])}</val>"
			end
			r.join("")
		else
			if v.respond_to?(:to_xml)
				begin
					v.to_xml(:skip_instruct => true).to_s
				rescue ArgumentError
					# Some to_xml methods don't understand skip_instruct
					v.to_xml.to_s
				end
			elsif v.respond_to?(:to_s)
				CGI::escapeHTML(v.to_s)
			else
				""
			end
		end
	end

	# FIXME: remove this method once we have a rails-xslt gem
	def side_data_to_xml(ctx)
		Nokogiri::XML::Builder.new do |env|
			env.send(:'side-data', 'xmlns' => 'http://svario.it/rails-xslt') do
				ctx.keys.each do |sym|
					env.send(sym.to_s.sub(/^@/, '')) do
						var = ctx[sym]
						env << simple_xmlify(var)
					end
				end
			end
		end.doc
	end
end
