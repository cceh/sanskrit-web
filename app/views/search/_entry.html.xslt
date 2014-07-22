<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_raw_xml.xsl"/>

	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict_handle/text()"/>
	<xsl:variable name="entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<rails:wrapper>
			<xsl:apply-templates select="$entry"/>

			<xsl:call-template name="raw-tei"/>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<dl>
			<xsl:apply-templates select="tei:form"/>
			<xsl:apply-templates select="tei:sense"/>
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
						<xsl:with-param name="root" select="$entry"/>
					</xsl:call-template>
				</code>
			</pre>
		</details>
	</xsl:template>
</xsl:stylesheet>
