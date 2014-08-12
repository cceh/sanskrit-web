<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_raw_xml.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:entry_bundle/rails:dict_handle/text()"/>
	<xsl:variable name="tei-entry" select="/rails:variables/rails:entry_bundle/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<rails:wrapper>
			<xsl:apply-templates select="$tei-entry"/>

			<xsl:call-template name="raw-tei"/>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<xsl:variable name="lemma" select="tei:form/tei:orth/text()"/>

		<xsl:variable name="lemma-url">
			<xsl:call-template name="lemma-url">
				<xsl:with-param name="entry" select="$tei-entry"/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>

		<dl>
			<xsl:apply-templates select="tei:form" mode="definition">
				<xsl:with-param name="linked-url" select="$lemma-url"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="tei:sense" mode="definition"/>
		</dl>
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
