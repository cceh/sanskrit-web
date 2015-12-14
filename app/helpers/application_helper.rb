require 'nokogiri'

module ApplicationHelper
	def render_xslt(bindings, cache_key_fn, data_enhancements_fn, include_globals=false)
		xslt_path = eval('__FILE__', bindings).sub(/\.erb$/, '.xslt')
		controller_name = eval('controller_name', bindings)
		_self = bindings.receiver

		rAILS_NS = "http://svario.it/xslt-rails"

		fRAMEWORK_VARIABLES = [:@_routes, :@_config, :@view_renderer, :@_db_runtime, :@_assigns, :@_controller, :@_request, :@view_flow, :@output_buffer, :@virtual_path, :@haml_buffer, :@marked_for_same_origin_verification]
		variables = _self.instance_variables - fRAMEWORK_VARIABLES

		all_variables = {}
		local_variables = {}
		global_variables = {}

		if bindings.local_variable_defined?(:local_assigns)
			local_variables = bindings.local_variable_get(:local_assigns)
		end

		overriden_include_globals = local_variables[:include_globals]
		if !overriden_include_globals.nil?
			include_globals = overriden_include_globals
		end
		if include_globals
			variables.each do |var_name|
				value = _self.instance_variable_get(var_name)
				global_variables[var_name] = value
			end
		end

		all_variables = local_variables.merge(global_variables)

		xslt_template_name = xslt_path.split('/').last(2).join('/').chomp('.html.xslt')
		cache_key = cache_key_fn[xslt_template_name, all_variables]
		if !cache_key.nil?
			cache_dir = Rails.root + 'tmp/cache/xslt'
			cache_file = (cache_dir + cache_key).sub_ext('.html')
			if cache_file.exist?
				Rails.logger.debug("XSLT Cache hit for #{cache_key}")
				return cache_file.read
			end
		end
		Rails.logger.debug("XSLT Cache MISS for #{cache_key}")

		data_enhancements_fn[all_variables, flash]

		wrapper = Nokogiri::XML("<rails:variables xmlns:rails='#{rAILS_NS}'/>")
		local_variables.each_pair do |var_name, value|
			wrapper.root << xml_element_for_variable(var_name, value)
		end
		if include_globals
			global_variables.each_pair do |var_name, value|
				wrapper.root << xml_element_for_variable(var_name, value)
			end
		end

		now = Time.now

		wrapper.root << xml_element_for_variable('date', now.strftime('%Y-%m-%d %H:%M:%S %z'))
		wrapper.root << xml_element_for_variable('request_base_url', request.base_url)
		wrapper.root << xml_element_for_variable('request_url', request.url)

		if Rails.logger.debug?
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

		cache_file.parent.mkpath
		cache_file.open('w') { |f| f << html }
		return html
	end

	# FIXME: use Builder instead of strings
	def xml_elements_for_value(v, doc)
		case v
		when Hash
			v.map do |key, value|
				name = acceptable_xml_name(key)
#				Rails.logger.debug "key = #{key.inspect}, name = #{name.inspect}"

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
#				Rails.logger.debug "v = #{v.inspect}"
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

	def ApplicationHelper.cache_key_for_rendering(xslt_template, variables)
		key = ""
		key += xslt_template + '/'
		variables.each_pair do |name, value|
			case name
			when :lemma, :@lemma
				nS = { 'tei' => 'http://www.tei-c.org/ns/1.0', }
				key += 'dict_' + value[:dict][:handle]
				key += '/'
				key += 'orth_' + value[:entry].at_xpath('tei:form/tei:orth/text()', nS)
				hom = value[:entry].at_xpath('tei:form/tei:milestone[@unit="hom"]/@n', nS)
				if !hom.nil?
					key += '-'
					key += 'hom_' + hom
				end
			when :@preceding_entries, :@following_entries
				# ignore
			when :entry, :partial_entry
				# ignore
			when :dict_handle
				key += value
			when :header
				# ignore
			when :@dict
				key += value[:handle]
			when :@scans
				# ignore
			when :@scan
				key += value.attr('xml:id')
			when :@best_format
				key += "_format-" + value.to_s
			when :@prev_scan, :@next_scan
				# ignore
			when :@dict_header
				# ignore
			when :@handle
				key += value
			when :@header
				# ignore
			when :@lemmas
				# ignore
			when :index_listing
				# ignore
			else
				raise "Cannot generate cache key for variable '#{name.inspect}'"
			end
		end

		return key
	end

	def ApplicationHelper.add_transliterations(vars, flash)
		add_missing_transliterations = lambda do |value|
			if value.nil? ; return ; end

			if value.is_a?(Hash) && value[:transliterations] == :MISSING
				tei_entry = value[:entry]

				transliterations, errors = Dictionary.transliterations_for_entry(tei_entry)
				value[:transliterations] = transliterations

				dict_handle = value[:dict][:handle]
				errors.each do |ex|
					tei_orth = tei_entry.xpath('.//text()[normalize-space(.) != "" ]').first
					error_message = "(in #{dict_handle}, #{tei_orth}) " + ex.message
					Rails.logger.error(error_message)
					Rails.logger.error(ex.cause)
					unless flash.now[:error].count >= 10
						flash.now[:error] << error_message
						flash.now[:cause] << ex.cause.inspect
					end
				end
			elsif value.is_a?(Array)
				value.each do |v|
					add_missing_transliterations[v]
				end
			else
				# ignore
				#raise "Variable kind not handled: #{value.class}"
			end
		end

		add_missing_transliterations[vars.values]
	end

	CACHE_KEY_FN = lambda { |xslt_name, vars| cache_key_for_rendering(xslt_name, vars) }
	ENHANCE_FN = lambda { |vars, flash| add_transliterations(vars, flash) }
end

# Licensed under the ISC licence, see LICENCE.ISC for details
