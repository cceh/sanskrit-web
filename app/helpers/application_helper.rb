module ApplicationHelper
	def render_xslt(bindings, include_globals=false)
		xslt_path = eval('__FILE__', bindings).sub(/\.erb$/, '.xslt')
		controller_name = eval('controller_name', bindings)
		_self = eval('self', bindings)

		require 'nokogiri'

		rAILS_NS = "http://svario.it/xslt-rails"

		fRAMEWORK_VARIABLES = [:@_routes, :@_config, :@view_renderer, :@_db_runtime, :@_assigns, :@_controller, :@_request, :@view_flow, :@output_buffer, :@virtual_path, :@haml_buffer, :@marked_for_same_origin_verification]
		variables = _self.instance_variables - fRAMEWORK_VARIABLES

		wrapper = Nokogiri::XML("<rails:variables xmlns:rails='#{rAILS_NS}'/>")

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

		now = Time.now

		wrapper.root << xml_element_for_variable('date', now.strftime('%Y-%m-%d %H:%M:%S %z'))
		wrapper.root << xml_element_for_variable('request_base_url', request.base_url)
		wrapper.root << xml_element_for_variable('request_url', request.url)

		if Rails.logger.level <= Logger::DEBUG
			now_str = now.strftime('%Y%m%d-%H%M%S-%6N')
			view_name = xslt_path.split('/').last.sub('.html.xslt', '')

			File.open(Rails.root + 'log' + "xslt-view-#{now_str}-#{controller_name}-#{view_name}.xml", 'w') do |xslt_input|
				xslt_input << wrapper
			end
		end

		view_dir = Rails.root + 'app/views' + controller_name

		$xslt_templates_cache ||= {}

		if !$xslt_templates_cache.has_key?(xslt_path)
			xslt_source = File.read(xslt_path)

			xslt_template = nil
			Dir.chdir(view_dir) do
				xslt_template = Nokogiri::XSLT(xslt_source)
			end

			$xslt_templates_cache[xslt_path] = xslt_template
		end


		xslt = $xslt_templates_cache[xslt_path]
		$xslt_templates_cache.delete(xslt_path) if Rails.env.development?
		root = xslt.transform(wrapper).root

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
				doc.parent << v
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
