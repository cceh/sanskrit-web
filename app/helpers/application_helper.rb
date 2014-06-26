module ApplicationHelper
	def render_xslt(bindings)
		xslt_path = eval('__FILE__', bindings).sub(/\.erb$/, '.xslt')
		_self = eval('self', bindings)

		require 'nokogiri'

		rAILS_NS = "http://svario.it/xslt-rails"

		fRAMEWORK_VARIABLES = [:@_routes, :@_config, :@view_renderer, :@_db_runtime, :@_assigns, :@_controller, :@_request, :@view_flow, :@output_buffer, :@virtual_path, :@haml_buffer]
		variables = _self.instance_variables - fRAMEWORK_VARIABLES

		wrapper = Nokogiri::XML("<rails:variables xmlns:rails='#{rAILS_NS}'>")

		variables.each do |var_name|
			wrapper.root << xml_element_for_variable(var_name, _self.instance_variable_get(var_name))
		end

		if bindings.local_variable_defined?('local_assigns')
			locals = bindings.local_variable_get('local_assigns')
			locals.each_pair do |var_name, value|
				wrapper.root << xml_element_for_variable(var_name, value)
			end
		end

		Rails.logger.debug wrapper

		xslt_source = File.read(xslt_path)
		xslt = Nokogiri::XSLT(xslt_source)

		root = xslt.transform(wrapper).root

		html = ''
		if !root.namespace.nil? && root.namespace.href == rAILS_NS && root.name == 'wrapper'
			html = root.children.map { |c| c.to_xml }.join('')
		else
			html = root.to_xml
		end

		return html
	end

	def xml_element_for_variable(sym, value)
		name = sym.to_s.sub(/^@/, '')

		Nokogiri::XML::Builder.new do |elem|
			elem.send("rails:#{name}", 'xmlns' => 'http://svario.it/xslt-rails') do
				elem << simple_xmlify(value)
			end
		end.doc.root
	end
end
