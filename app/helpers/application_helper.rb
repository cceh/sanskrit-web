module ApplicationHelper
	def render_xslt(bindings, include_globals=false)
		xslt_path = eval('__FILE__', bindings).sub(/\.erb$/, '.xslt')
		controller_name = eval('controller_name', bindings)
		_self = eval('self', bindings)

		require 'nokogiri'

		rAILS_NS = "http://svario.it/xslt-rails"

		fRAMEWORK_VARIABLES = [:@_routes, :@_config, :@view_renderer, :@_db_runtime, :@_assigns, :@_controller, :@_request, :@view_flow, :@output_buffer, :@virtual_path, :@haml_buffer, :@marked_for_same_origin_verification]
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

		view_dir = Rails.root + 'app/views' + controller_name

		root = nil
		Dir.chdir(view_dir) do
			xslt = Nokogiri::XSLT(xslt_source)
			root = xslt.transform(wrapper).root
		end

		if root.nil?
			raise "XSLT Transformation #{xslt_path.sub(Rails.root.to_s, '')} failed (Empty result)"
		end

		save_opts = { :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML }

		html = ''
		if !root.namespace.nil? && root.namespace.href == rAILS_NS && root.name == 'wrapper'
			html = root.children.map { |c| c.to_xml(save_opts) }.join("\n")
		else
			html = root.to_xml(save_opts)
		end

		return html
	end

	# FIXME: use Builder instead of strings
	def xml_elements_for_value(v, doc)
		case v
		when Hash
			v.map do |key, value|
				name = acceptable_xml_name(key)
				Rails.logger.debug "key = #{key.inspect}, name = #{name.inspect}"

				attrs = {}
				attrs[:orig_key] = key.to_s unless name == key.to_s

				doc.send("rails:#{name}", attrs) do
					xml_elements_for_value(value, doc)
				end
			end
		when Array
			v.map do |value|
				doc.send('rails:elem') do
					xml_elements_for_value(value, doc)
				end
			end
		else
			if v.respond_to?(:to_xml)
				begin
					doc << v.to_xml(:skip_instruct => true).to_s
				rescue ArgumentError
					# Some to_xml methods don't understand skip_instruct
					doc << v.to_xml.to_s
				end
			elsif v.respond_to?(:to_s)
				Rails.logger.debug "v = #{v.inspect}"
				doc.text v.to_s
			else
				raise "Cannot XMLify #{v.inspect}"
			end
		end
	end

	def xml_element_for_variable(sym, value)
		name = acceptable_xml_name(sym)

		Nokogiri::XML::Builder.new do |elem|
			elem.send("rails:#{name}", 'xmlns' => 'http://svario.it/xslt-rails') do
				xml_elements_for_value(value, elem)
			end
		end.doc.root
	end

	def acceptable_xml_name(sym)
		name = sym.to_s.dup
		name.sub!(/^@/, '')
		name.gsub!(/[^A-Za-z0-9_\-]/, '-')
		name = CGI::escapeHTML(name)

		if name =~ /^[^A-Za-z]/
			name = 'x' + name
		end

		return name
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
