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

		Rails.logger.debug wrapper

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

	def xml_element_for_variable(sym, value)
		name = sym.to_s.sub(/^@/, '')

		Nokogiri::XML::Builder.new do |elem|
			elem.send("rails:#{name}", 'xmlns' => 'http://svario.it/xslt-rails') do
				elem << simple_xmlify(value)
			end
		end.doc.root
	end
end
