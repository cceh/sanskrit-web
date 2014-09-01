<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="scans-url">./scan</xsl:variable> <!-- FIXME: get from controller -->

	<xsl:template match="/">
		<xsl:apply-templates select="/rails:variables/rails:scan"/>
	</xsl:template>

	<xsl:template match="rails:scan">
		<xsl:variable name="graphic" select="./tei:graphic"/>

		<xsl:variable name="page-code">
			<xsl:call-template name="page-code">
				<xsl:with-param name="graphic" select="./tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="page-name">
			<xsl:call-template name="page-name">
				<xsl:with-param name="graphic" select="./tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<li>
			<a href="{$scans-url}/{$page-code}">
				<xsl:value-of select="$page-name"/>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
