<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_raw_xml.xsl"/>
	<xsl:import href="../shared/_chars.xsl"/>
	<xsl:import href="../shared/_info.xsl"/>

	<xsl:variable name="dict-info" select="/rails:variables/rails:lemma/rails:dict"/>
	<xsl:variable name="dict-handle" select="$dict-info/rails:handle/text()"/>
	<xsl:variable name="dict-common-title" select="$dict-info/rails:common_title/text()"/>
	<xsl:variable name="dict-orig-author" select="$dict-info/rails:orig_author/text()"/>

	<xsl:variable name="tei-entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>
	<xsl:variable name="preceding-entries" select="/rails:variables/rails:preceding_entries/rails:elem/rails:entry/*[self::tei:entry or self::tei:re]"/>
	<xsl:variable name="following-entries" select="/rails:variables/rails:following_entries/rails:elem/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<rails:wrapper>
			<xsl:apply-templates select="$tei-entry"/>

			<xsl:value-of select="$char-newline"/>
			<xsl:call-template name="raw-tei-snippet">
				<xsl:with-param name="tei-element" select="$tei-entry"/>
			</xsl:call-template>

			<xsl:value-of select="$char-newline"/>
			<xsl:call-template name="adjacent-entries"/>

			<xsl:value-of select="$char-newline"/>
			<xsl:call-template name="citation-instructions"/>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<h1>
			<xsl:apply-templates select="tei:form" mode="heading"/>
		</h1>

		<dl>
			<xsl:apply-templates select="tei:form" mode="definition"/>
			<xsl:apply-templates select="tei:sense" mode="definition"/>
		</dl>
	</xsl:template>

	<xsl:template name="adjacent-entries">
		<h2>
			<xsl:text>Surrounding entries in</xsl:text>
			<xsl:value-of select="$char-space"/>
			<xsl:value-of select="$dict-common-title"/>
		</h2>

		<ol class="results adjacent">
			<xsl:apply-templates select="$preceding-entries" mode="adjacent">
				<xsl:with-param name="class">preceding</xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select="$tei-entry" mode="adjacent">
				<xsl:with-param name="class">current</xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select="$following-entries" mode="adjacent">
				<xsl:with-param name="class">following</xsl:with-param>
			</xsl:apply-templates>
		</ol>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re" mode="adjacent">
		<xsl:param name="class"/>

		<xsl:variable name="lemma-url">
			<xsl:call-template name="lemma-url">
				<xsl:with-param name="tei-entry" select="."/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>

		<li class="{$class}">
			<xsl:apply-templates select="tei:form" mode="listing">
				<xsl:with-param name="linked-url" select="$lemma-url"/>
			</xsl:apply-templates>
		</li>
		<xsl:value-of select="$char-newline"/>
	</xsl:template>

	<xsl:template name="citation-instructions">
		<xsl:variable name="lemma-title">
			<xsl:call-template name="text-and-transliterations">
				<xsl:with-param name="text" select="$tei-entry/tei:form/tei:orth"/>
				<xsl:with-param name="rails-entry" select="$tei-entry/.."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="lemma-id">
			<xsl:call-template name="lemma-url">
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
				<xsl:with-param name="tei-entry" select="$tei-entry"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="lemma-url" select="/rails:variables/rails:request_url/text()"/>
		<xsl:variable name="author" select="$dict-orig-author"/>
		<xsl:variable name="publication" select="$dict-common-title"/>
		<xsl:variable name="publication-url">
			<xsl:value-of select="/rails:variables/rails:request_base_url/text()"/>
			<xsl:call-template name="dict-url">
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="project-url" select="/rails:variables/rails:request_base_url/text()"/>
		<xsl:variable name="date" select="substring-before(/rails:variables/rails:date/text(), ' ')"/>

		<xsl:value-of select="$char-newline"/>
		<details class="citation-instructions">
			<xsl:value-of select="$char-newline"/>
			<summary>
				<xsl:text>Cite this entry</xsl:text>
			</summary>

			<xsl:value-of select="$char-newline"/>
			<div>
				<xsl:value-of select="$char-newline"/>
				<dl>

					<xsl:value-of select="$char-newline"/>
					<dt><xsl:text>Text (for LibreOffice and Microsoft Word)</xsl:text></dt>
					<dd>
						<p>
							<xsl:value-of select="$lemma-title"/>
							<xsl:text>.</xsl:text>
							<xsl:value-of select="$char-space"/>

							<xsl:text>In</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$publication"/>
							<xsl:text>.</xsl:text>
							<xsl:value-of select="$char-space"/>

							<xsl:text>Retrieved</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$date"/>
							<xsl:text>,</xsl:text>
							<xsl:value-of select="$char-space"/>

							<xsl:text>from</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$lemma-url"/>
						</p>
					</dd>

					<xsl:value-of select="$char-newline"/>
					<dt><xsl:text>BibTeX</xsl:text></dt>
					<dd>
						<pre style="white-space: pre-line"><code>
							<xsl:variable name="indent">
								<span style="white-space: pre">
									<xsl:value-of select="$char-space"/>
									<xsl:value-of select="$char-space"/>
									<xsl:value-of select="$char-space"/>
									<xsl:value-of select="$char-space"/>
								</span>
							</xsl:variable>

							<xsl:text>@misc{</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>csl:</xsl:text>
							<xsl:value-of select="$lemma-id"/>
							<xsl:text>,</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>author = "</xsl:text>
							<xsl:value-of select="$author"/>
							<xsl:text>",</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>title = {{</xsl:text>
							<xsl:value-of select="$lemma-title"/>
							<xsl:value-of select="$char-space"/>
							<xsl:text>---</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$publication"/>
							<xsl:text>}},</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>publisher = "</xsl:text>
							<xsl:value-of select="$project-name"/>
							<xsl:text>",</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>url = "\url{</xsl:text>
							<xsl:value-of select="$lemma-url"/>
							<xsl:text>}",</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:copy-of select="$indent"/>
							<xsl:text>note = "[Online; accessed </xsl:text>
							<xsl:value-of select="$date"/>
							<xsl:text>]"</xsl:text>
							<xsl:value-of select="$char-newline"/>

							<xsl:text>}</xsl:text>
						</code></pre>
					</dd>

					<xsl:value-of select="$char-newline"/>
					<dt><xsl:text>Mediawiki format (for Wikipedia)</xsl:text></dt>
					<dd>
						<p>
							<xsl:text>Entry "</xsl:text>

							<xsl:text>[</xsl:text>
							<xsl:value-of select="$lemma-url"/>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$lemma-title"/>
							<xsl:text>]</xsl:text>

							<xsl:text>" in</xsl:text>

							<xsl:value-of select="$char-space"/>

							<xsl:text>[</xsl:text>
							<xsl:value-of select="$publication-url"/>
							<xsl:value-of select="$char-space"/>

							<xsl:value-of select="$publication"/>
							<xsl:value-of select="$char-space"/>

							<xsl:text>by</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$author"/>
							<xsl:text>]</xsl:text>

							<xsl:text>, </xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:text>[</xsl:text>
							<xsl:value-of select="$project-url"/>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$project-name"/>
							<xsl:text>]</xsl:text>

							<xsl:value-of select="$char-space"/>

							<xsl:text>(accessed</xsl:text>
							<xsl:value-of select="$char-space"/>
							<xsl:value-of select="$date"/>
							<xsl:text>)</xsl:text>
						</p>
					</dd>
				</dl>
				<xsl:value-of select="$char-newline"/>

			</div>
		</details>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
