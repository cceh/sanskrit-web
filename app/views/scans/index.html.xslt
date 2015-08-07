<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_scans_helper.xsl"/>

	<xsl:import href="../shared/_chars.xsl"/>
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="dict-info" select="/rails:variables/rails:dict"/>
	<xsl:variable name="dict-handle" select="$dict-info/rails:handle/text()"/>
	<xsl:variable name="dict-common-title" select="$dict-info/rails:common_title/text()"/>

	<xsl:variable name="count" select="count(/rails:variables/rails:lemmas/rails:elem)"/>

	<xsl:template match="/">
		<rails:wrapper>
			<h1>
				<xsl:text>Scans of</xsl:text>
				<xsl:value-of select="$char-space"/>
				<xsl:value-of select="$dict-common-title"/>
			</h1>

			<xsl:apply-templates select="/rails:variables/rails:scans"/>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="rails:scans">
		<ol>
			<xsl:apply-templates/>
		</ol>
	</xsl:template>

	<xsl:template match="tei:graphic">
		<xsl:variable name="class">
			<xsl:text>tei-</xsl:text>
			<xsl:value-of select="local-name()"/>
		</xsl:variable>

		<xsl:variable name="page-code">
			<xsl:call-template name="page-code">
				<xsl:with-param name="graphic" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="page-name">
			<xsl:call-template name="page-name">
				<xsl:with-param name="graphic" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- FIXME: use scan-url in place of `page-code` and `page-name`
		<xsl:variable name="scan-url">
			<xsl:call-template name="scan-url">
				<xsl:with-param name="graphic-or-page-ref" select="."/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>
		-->

		<xsl:variable name="scans-url">./scan</xsl:variable> <!-- FIXME: get from controller -->
		<xsl:variable name="scan-url">
			<xsl:value-of select="$scans-url"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$page-code"/>
		</xsl:variable>

		<li class="{$class}">
			<a href="{$scan-url}">
				<xsl:value-of select="$page-name"/>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
