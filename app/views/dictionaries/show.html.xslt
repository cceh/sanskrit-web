<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="handle" select="/rails:variables/rails:handle"/>

	<xsl:template match="/rails:variables/rails:header/tei:teiHeader">
		<xsl:variable name="desc-title" select=".//tei:titleStmt/tei:title[@type='desc']"/>
		<xsl:variable name="orig-title" select=".//tei:sourceDesc//tei:title[@type='main']"/>
		<xsl:variable name="orig-sub-title" select=".//tei:sourceDesc//tei:title[@type='sub']"/>

		<xsl:variable name="author" select=".//tei:sourceDesc//tei:author"/>

		<rails:wrapper>
			<h1>
				<xsl:value-of select="$desc-title"/>
			</h1>

			<p>
				<xsl:text>Originally: </xsl:text>
				<xsl:value-of select="$orig-title"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$orig-sub-title"/>
			</p>

			<p>
				<xsl:text>By </xsl:text>
				<xsl:value-of select="$author"/>
				<xsl:text>.</xsl:text>
			</p>

			<p>
				<xsl:text>The </xsl:text>
				<xsl:value-of select="$desc-title"/>
				<xsl:text> dictionary contains </xsl:text>
				<xsl:text>FIXME(10000)</xsl:text>
				<xsl:value-of select="$space-char"/>
				<xsl:text>FIXME(Sanskrit)</xsl:text>
				<xsl:text> lemmas translated into </xsl:text>
				<xsl:text>FIXME(English)</xsl:text>
				<xsl:text>.</xsl:text>
			</p>

			<a href="{$handle}/lemmas">
				<xsl:text>Browse lemmas</xsl:text>
			</a>

			<a href="{$handle}/scans">
				<xsl:text>Browse scans</xsl:text>
			</a>

			<a href="../search?dict={$handle}">
				<xsl:text>Search inside</xsl:text>
			</a>
		</rails:wrapper>
	</xsl:template>
</xsl:stylesheet>
