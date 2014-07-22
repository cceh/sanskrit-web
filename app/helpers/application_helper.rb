module ApplicationHelper
	def render_xslt(bindings, include_globals=false)
		xslt_path = eval('__FILE__', bindings).sub(/\.erb$/, '.xslt')
		controller_name = eval('controller_name', bindings)
		_self = eval('self', bindings)

		require 'nokogiri'

		rAILS_NS = "http://svario.it/xslt-rails"

		fRAMEWORK_VARIABLES = [:@_routes, :@_config, :@view_renderer, :@_db_runtime, :@_assigns, :@_controller, :@_request, :@view_flow, :@output_buffer, :@virtual_path, :@haml_buffer]
		variables = _self.instance_variables - fRAMEWORK_VARIABLES

		wrapper = Nokogiri::XML("<rails:variables xmlns:rails='#{rAILS_NS}'>")

		if bindings.local_variable_defined?('local_assigns')
			locals = bindings.local_variable_get('local_assigns')

			overriden_include_globals = locals['include_globals']
			if !overriden_include_globals.nil?
				include_globals = overriden_include_globals
			end

			locals.each_pair do |var_name, value|
				wrapper.root << xml_element_for_variable(var_name, value)
			end
		end

		if include_globals
			variables.each do |var_name|
				wrapper.root << xml_element_for_variable(var_name, _self.instance_variable_get(var_name))
			end
		end

		if Rails.logger.level <= Logger::DEBUG
			now = Time.now.strftime('%Y%m%d-%H%M%S-%6N')
			view_name = xslt_path.split('/').last.sub('.html.xslt', '')

			File.open(Rails.root + 'log' + "xslt-view-#{now}-#{controller_name}-#{view_name}.xml", 'w') do |xslt_input|
				xslt_input << wrapper
			end
		end

		xslt_source = File.read(xslt_path)

		helper_path = Rails.root + "app/helpers/#{controller_name}_helper.xsl"
		if File.exists?(helper_path)
			elem = "<import href='#{helper_path}' xmlns='http://www.w3.org/1999/XSL/Transform'/>"
			xslt_source.sub!(/(stylesheet .*?)>/m, '\1>' + elem)
		end

		xslt = Nokogiri::XSLT(xslt_source)
		root = xslt.transform(wrapper).root

		html = ''
		if !root.namespace.nil? && root.namespace.href == rAILS_NS && root.name == 'wrapper'
			html = root.children.map { |c| c.to_xml }.join("\n")
		else
			html = root.to_xml
		end

		return html
	end

	# FIXME: use Builder instead of strings
	def xml_elements_for_value(v)
		case v
		when Hash
			v.map do |key, value|
				name = acceptable_xml_name(key)
				if name != key.to_s
					orig_key = " orig-key='#{CGI::escapeHTML(key.to_s)}'"
				end
				"<rails:#{name}#{orig_key}>" +
				xml_elements_for_value(value) +
				"</rails:#{name}>"
			end.join("")
		when Array
			v.map do |value|
				"<rails:elem>" +
				xml_elements_for_value(value) +
				"</rails:elem>"
			end.join("")
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
				raise "Cannot XMLify #{v.inspect}"
			end
		end
	end

	def xml_element_for_variable(sym, value)
		name = acceptable_xml_name(sym)

		Nokogiri::XML::Builder.new do |elem|
			elem.send("rails:#{name}", 'xmlns' => 'http://svario.it/xslt-rails') do
				elem << xml_elements_for_value(value)
			end
		end.doc.root
	end

	def acceptable_xml_name(sym)
		name = sym.to_s.dup
		name.sub!(/^@/, '')
		name.gsub!(/[<>{}\[\]*:\/]/, '')
		name = CGI::escapeHTML(name)

		return name
	end
end
