<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_chars.xsl"/>

	<xsl:template match="tei:sourceDesc">
		<p  class="tei-{name()}">
			<xsl:apply-templates select="(.//tei:titleStmt)[1]"/>
		</p>
	</xsl:template>

	<xsl:template match="tei:editionStmt">
		<p  class="tei-{name()}">
			<xsl:apply-templates select="(.//tei:edition)[1]"/>
		</p>

		<xsl:apply-templates select=".//tei:respStmt"/>
	</xsl:template>

	<xsl:template match="tei:seriesStmt">
		<p class="tei-{name()}">
			<xsl:apply-templates select=".//tei:title"/>
		</p>
	</xsl:template>

	<xsl:template match="tei:respStmt[*[1][self::tei:resp]]">
		<p class="tei-{name()}">
			<xsl:apply-templates select="tei:resp"/>
			<xsl:value-of select="$char-space"/>
			<xsl:apply-templates select="node()[not(self::tei:resp)]"/>
		</p>
	</xsl:template>

	<xsl:template match="tei:respStmt[not(*[1][self::tei:resp])]">
		<p class="tei-{name()}">
			<xsl:apply-templates select="node()[not(self::tei:resp)]"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$char-space"/>
			<xsl:apply-templates select="tei:resp"/>
		</p>
	</xsl:template>

	<xsl:template match="tei:affiliation">
		<span class="tei-{name()}">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:text>)</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="tei:orgName">
		<span class="tei-{name()}">
			<xsl:value-of select="normalize-space(.)"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:persName">
		<span class="tei-{name()}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<xsl:template match="tei:resp">
		<span class="tei-{name()}">
			<xsl:value-of select="normalize-space(.)"/>
		</span>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
