<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_raw_xml.xsl"/>
	<xsl:import href="../shared/_chars.xsl"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict_handle/text()"/>
	<xsl:variable name="tei-entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>
	<xsl:variable name="preceding-entries" select="/rails:variables/rails:preceding_entries/rails:elem/rails:entry/*[self::tei:entry or self::tei:re]"/>
	<xsl:variable name="following-entries" select="/rails:variables/rails:following_entries/rails:elem/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<rails:wrapper>
			<xsl:apply-templates select="$tei-entry"/>

			<xsl:value-of select="$char-newline"/>
			<xsl:call-template name="raw-tei"/>

			<xsl:value-of select="$char-newline"/>
			<xsl:call-template name="adjacent-entries"/>
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
			<xsl:text>Previous and following entries in</xsl:text>
			<xsl:value-of select="$char-space"/>
			<xsl:value-of select="$dict-handle"/><xsl:text> (FIXME: use proper name)</xsl:text>
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
				<xsl:with-param name="entry" select="."/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>

		<li class="{$class}">
			<xsl:apply-templates select="tei:form" mode="definition">
				<xsl:with-param name="linked-url" select="$lemma-url"/>
			</xsl:apply-templates>
		</li>
		<xsl:value-of select="$char-newline"/>
	</xsl:template>

	<xsl:template name="raw-tei">
		<details class="raw-tei">
			<summary>
				<xsl:text>[click to show TEI-XML code…]</xsl:text>
			</summary>
			<pre>
				<code>
					<xsl:call-template name="raw-xml">
						<xsl:with-param name="root" select="$tei-entry"/>
					</xsl:call-template>
				</code>
			</pre>
		</details>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
