<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="url-root" select="string(/rails:variables/rails:relative_url_root)"/>

	<xsl:variable name="tei-entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<xsl:apply-templates select="$tei-entry"/>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<xsl:variable name="lemma" select="tei:form/tei:orth/text()"/>

		<xsl:variable name="search-url">
			<xsl:call-template name="search-url">
				<xsl:with-param name="text" select="$lemma"/>
				<xsl:with-param name="url-root" select="$url-root"/>
			</xsl:call-template>
		</xsl:variable>

		<li>
			<a href="{$search-url}" class="lemma search">
				<xsl:call-template name="text-and-transliterations">
					<xsl:with-param name="text" select="$lemma"/>
					<xsl:with-param name="rails-entry" select="parent::rails:entry"/>
				</xsl:call-template>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
