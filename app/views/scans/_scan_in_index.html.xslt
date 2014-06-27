<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="scans-url">./scan</xsl:variable> <!-- FIXME: get from controller -->

	<xsl:template match="/">
		<xsl:apply-templates select="/rails:variables/rails:scan"/>
	</xsl:template>

	<xsl:template match="rails:scan">
		<xsl:variable name="graphic" select="./tei:graphic"/>

		<li>
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="$scans-url"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$graphic/@xml:id"/>
				</xsl:attribute>

				<xsl:value-of select="$graphic/@xml:id"/>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>
