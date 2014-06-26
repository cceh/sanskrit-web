<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/rails-xslt"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="side-data" select="//rails:side-data"/>

	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="handle" select="$side-data/rails:handle"/>

	<xsl:template match="/tei:teiHeader">
		<xsl:variable name="desc-title" select=".//tei:titleStmt/tei:title[@type='desc']"/>
		<xsl:variable name="orig-title" select=".//tei:titleStmt/tei:title[@type='main']"/>
		<xsl:variable name="orig-sub-title" select=".//tei:titleStmt/tei:title[@type='sub']"/>

		<xsl:variable name="author" select=".//tei:titleStmt/tei:author"/>

		<section>
			<h2>
				<a href="../dictionary/{$handle}">
					<xsl:value-of select="$desc-title"/>
				</a>
			</h2>

			<p>
				<xsl:text>Originally: </xsl:text>
				<xsl:value-of select="$orig-title"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$orig-sub-title"/>
			</p>
			<p>
				<xsl:text>By </xsl:text>
				<xsl:value-of select="$author"/>
			</p>

			<a href="../dictionary/{$handle}">
				<xsl:text>More info</xsl:text>
			</a>

			<a href="../dictionary/{$handle}/scans">
				<xsl:text>Browse</xsl:text>
			</a>

			<a href="../search?dict={$handle}">
				<xsl:text>Search inside</xsl:text>
			</a>
		</section>
	</xsl:template>
</xsl:stylesheet>