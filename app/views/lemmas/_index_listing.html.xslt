<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="url-root" select="string(/rails:variables/rails:relative_url_root)"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict/rails:handle/text()"/>
	<xsl:variable name="rails-entry" select="/rails:variables/rails:lemma/rails:entry"/>
	<xsl:variable name="tei-entry" select="$rails-entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<xsl:apply-templates select="$tei-entry"/>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<xsl:variable name="class">
			<xsl:text>tei-</xsl:text>
			<xsl:value-of select="local-name()"/>
			<!-- FIXME: extra parameter for deeply nested entries -->
		</xsl:variable>

		<li class="{$class}">
			<xsl:variable name="lemma-url">
				<xsl:call-template name="lemma-url">
					<xsl:with-param name="tei-entry" select="$tei-entry"/>
					<xsl:with-param name="dict-handle" select="$dict-handle"/>
					<xsl:with-param name="url-root" select="$url-root"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:call-template name="text-and-transliterations">
				<xsl:with-param name="text" select="$tei-entry/tei:form/tei:orth"/>
				<xsl:with-param name="linked-url" select="$lemma-url"/>
				<xsl:with-param name="rails-entry" select="$rails-entry"/>
			</xsl:call-template>
		</li>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
